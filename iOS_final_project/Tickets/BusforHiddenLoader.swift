//
//  BusforHiddenLoader.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 9.03.26.
//

import Foundation
import WebKit

final class BusforHiddenLoader: NSObject {
    
    struct ResultData {
        let html: String
        let searchId: String?
        let apiUrls: [String]
    }
    
    private var webView: WKWebView?
    private var completion: ((Result<ResultData, Error>) -> Void)?
    
    func load(
        fromId: Int,
        toId: Int,
        date: String,
        passengers: Int = 1,
        completion: @escaping (Result<ResultData, Error>) -> Void
    ) {
        self.completion = completion
        
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        self.webView = webView
        
        let rawURL = "https://busfor.by/автобусы/Минск/Варшава?from_id=\(fromId)&to_id=\(toId)&on=\(date)&passengers=\(passengers)&search=true"
        
        guard let encoded = rawURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
              let url = URL(string: encoded) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.setValue("https://busfor.by", forHTTPHeaderField: "Referer")
        
        webView.load(request)
    }
    
    func load(
        fromId: Int,
        toId: Int,
        date: String,
        passengers: Int = 1
    ) async throws -> ResultData {
        try await withCheckedThrowingContinuation { continuation in
            load(
                fromId: fromId,
                toId: toId,
                date: date,
                passengers: passengers
            ) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private func finish(with result: Result<ResultData, Error>) {
        completion?(result)
        completion = nil
        webView?.navigationDelegate = nil
        webView = nil
    }
    
    private func extractAllData() {
        guard let webView else { return }
        
        let group = DispatchGroup()
        
        var htmlResult: String?
        var apiUrlsResult: [String] = []
        var jsError: Error?
        
        group.enter()
        webView.evaluateJavaScript("document.documentElement.outerHTML") { result, error in
            defer { group.leave() }
            
            if let error {
                jsError = error
                return
            }
            
            htmlResult = result as? String
        }
        
        group.enter()
        webView.evaluateJavaScript("""
        performance.getEntriesByType('resource')
            .map(item => item.name)
            .filter(url => url.includes('/api/v1/searches'))
        """) { result, error in
            defer { group.leave() }
            
            if let error {
                print("Performance JS error:", error)
                return
            }
            
            if let urls = result as? [String] {
                apiUrlsResult = urls
            }
        }
        
        group.notify(queue: .main) {
            if let jsError {
                self.finish(with: .failure(jsError))
                return
            }
            
            guard let html = htmlResult else {
                self.finish(with: .failure(URLError(.cannotParseResponse)))
                return
            }
            
            let searchId = self.extractSearchId(from: html, apiUrls: apiUrlsResult)
            
            let result = ResultData(
                html: html,
                searchId: searchId,
                apiUrls: apiUrlsResult
            )
            
            self.finish(with: .success(result))
        }
    }
    
    private func extractSearchId(from html: String, apiUrls: [String]) -> String? {
        for url in apiUrls {
            if let id = extractSearchId(from: url) {
                return id
            }
        }
        
        let patterns = [
            #"/api/v1/searches/([A-Za-z0-9\-_]+)"#,
            #"searches/([A-Za-z0-9\-_]+)\?"#
        ]
        
        for pattern in patterns {
            if let value = firstMatch(in: html, pattern: pattern, group: 1) {
                return value
            }
        }
        
        return nil
    }
    
    private func extractSearchId(from text: String) -> String? {
        firstMatch(
            in: text,
            pattern: #"/api/v1/searches/([A-Za-z0-9\-_]+)"#,
            group: 1
        )
    }
    
    private func firstMatch(in text: String, pattern: String, group: Int) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
            
            guard let match = regex.firstMatch(in: text, range: nsRange),
                  let range = Range(match.range(at: group), in: text) else {
                return nil
            }
            
            return String(text[range])
        } catch {
            return nil
        }
    }
}

extension BusforHiddenLoader: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Hidden WKWebView loaded page")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.extractAllData()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        finish(with: .failure(error))
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        finish(with: .failure(error))
    }
}
