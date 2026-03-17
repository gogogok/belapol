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
        let checkoutUrl: String
    }
    
    private enum Constants {
        static let timeout: TimeInterval = 40
        static let extractDelay: TimeInterval = 2.0
        static let minskId = 4102
        static let warsawId = 3465
    }
    
    private var webView: WKWebView?
    private var completion: ((Result<ResultData, Error>) -> Void)?
    private var timeoutWorkItem: DispatchWorkItem?
    private var isFinished = false
    private var url: String = " "
    
    func load (
        fromId: Int,
        toId: Int,
        date: String,
        passengers: Int = 1,
        completion: @escaping (Result<ResultData, Error>) -> Void
    ) {
        self.completion = completion
        
        let config = WKWebViewConfiguration()
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        self.webView = webView
        
        guard fromId != toId else {
            finish(
                with: .failure(
                    NSError(
                        domain: "BusforHiddenLoader",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Пункт назначения совпадает с пунктом отправления"]
                    )
                )
            )
            return
        }
        
        var rawURL = "https://busfor.by/автобусы/Минск/Варшава?from_id=\(fromId)&to_id=\(toId)&on=\(date)&passengers=\(passengers)&search=true"
        
        if (fromId == 3465 && toId == 4102) {
            rawURL = "https://busfor.by/автобусы/Варшава/Минск?from_id=\(fromId)&to_id=\(toId)&on=\(date)&passengers=\(passengers)&search=true"
        }
        url = rawURL
        
        
        guard let encoded = rawURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
              let url = URL(string: encoded) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = Constants.timeout
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.setValue("https://busfor.by", forHTTPHeaderField: "Referer")
        
        print("Trying URL:", url.absoluteString)
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.finish(with: .failure(URLError(.timedOut)))
        }
        timeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.timeout, execute: workItem)
        
        webView.load(request)
    }
    
    func load(
        fromId: Int,
        toId: Int,
        date: String,
        passengers: Int = 1
    ) async throws -> ResultData {
        try await withCheckedThrowingContinuation{ continuation in
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
                apiUrls: apiUrlsResult,
                checkoutUrl: self.url
            )
            
            self.finish(with: .success(result))
        }
    }
    
    private func extractCheckoutUrls(from html: String) -> [String] {
        let patterns = [
            #"https:\/\/busfor\.by\/ru\/new\/checkout\/-?\d+"#,
            #"\/ru\/new\/checkout\/-?\d+"#
        ]

        var result: [String] = []

        for pattern in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let nsRange = NSRange(html.startIndex..<html.endIndex, in: html)

                let matches = regex.matches(in: html, range: nsRange)

                let values = matches.compactMap { match -> String? in
                    guard let range = Range(match.range, in: html) else { return nil }
                    let value = String(html[range])

                    if value.hasPrefix("http") {
                        return value
                    } else {
                        return "https://busfor.by" + value
                    }
                }

                result.append(contentsOf: values)
            } catch {
                print("Regex error:", error)
            }
        }

        return Array(Set(result))
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        print("Hidden WKWebView loaded page")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.extractAllData()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        finish(with: .failure(error))
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        finish(with: .failure(error))
    }
}
