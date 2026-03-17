//
//  SputnikNewsService.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 14.03.26.
//

import UIKit
import SwiftSoup

enum NewsParserError: Error {
    case invalidURL
    case invalidHTML
    case newsNotFound
    case imageLoadingFailed
}

final class SputnikNewsService {
    
    typealias Model = NewsModel
    
    // MARK: - Constants
    private enum Constants {
        static let baseURL = "https://sputnik.by"
        static let listURLString = "https://sputnik.by/geo_Polsha/"
        static let maxNewsCount = 10
        static let minTitleLength = 25
        static let placeholderDate = "—"
        static let placeholderSubtitle = "Без описания"
    }
    
    struct PreviewItem {
        let title: String
        let dateText: String
        let articleURLString: String
    }
    
    // MARK: - Public
    func fetchLatestNews() async throws -> [Model.NewsVM] {
        let previews = try await fetchPreviewItems()
        
        guard !previews.isEmpty else {
            throw NewsParserError.newsNotFound
        }
        
        return try await withThrowingTaskGroup(of: (Int, Model.NewsVM?).self) { group in
            for (index, preview) in previews.enumerated() {
                group.addTask {
                    do {
                        let news = try await self.fetchFullNews(from: preview)
                        return (index, news)
                    } catch {
                        return (index, nil)
                    }
                }
            }
            
            var orderedResults = Array<Model.NewsVM?>(repeating: nil, count: previews.count)
            
            for try await (index, news) in group {
                orderedResults[index] = news
            }
            
            let result = orderedResults.compactMap { $0 }
            
            if result.isEmpty {
                throw NewsParserError.newsNotFound
            }
            
            return result
        }
    }
}

// MARK: - Preview Loading
private extension SputnikNewsService {
    
    func fetchPreviewItems() async throws -> [PreviewItem] {
        guard let url = URL(string: Constants.listURLString) else {
            throw NewsParserError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NewsParserError.invalidHTML
        }
        
        let doc = try SwiftSoup.parse(html)
        let links = try doc.select("a[href]")
        
        var result: [PreviewItem] = []
        var seenURLs = Set<String>()
        
        for link in links.array() {
            let href = try link.attr("href").trimmingCharacters(in: .whitespacesAndNewlines)
            let title = try link.text().trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard isValidArticleLink(href) else { continue }
            guard title.count >= Constants.minTitleLength else { continue }
            
            let articleURLString = makeAbsoluteURL(from: href)
            guard !seenURLs.contains(articleURLString) else { continue }
            
            let containerText = try link.parent()?.text() ?? ""
            let dateText = extractFirstTime(from: containerText) ?? Constants.placeholderDate
            
            result.append(
                PreviewItem(
                    title: title,
                    dateText: dateText,
                    articleURLString: articleURLString
                )
            )
            
            seenURLs.insert(articleURLString)
            
            if result.count == Constants.maxNewsCount {
                break
            }
        }
        
        return result
    }
    
    func isValidArticleLink(_ href: String) -> Bool {
        href.contains(".html") && !href.contains("#")
    }
    
    func makeAbsoluteURL(from href: String) -> String {
        if href.hasPrefix("http") {
            return href
        }
        
        return Constants.baseURL + href
    }
}
    
// MARK: - Full Article Loading
private extension SputnikNewsService {
    
    func fetchFullNews(from preview: PreviewItem) async throws -> Model.NewsVM {
        guard let url = URL(string: preview.articleURLString) else {
            throw NewsParserError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NewsParserError.invalidHTML
        }
        
        let doc = try SwiftSoup.parse(html)
        
        let title = try extractTitle(from: doc) ?? preview.title
        let subtitle = try extractSubtitle(from: doc) ?? Constants.placeholderSubtitle
        let dateText = try extractDate(from: doc) ?? preview.dateText
        let image = try await loadImage(from: doc)
        
        return Model.NewsVM(
            title: title,
            dateText: dateText,
            subtitle: subtitle,
            image: image,
            url: url,
            isTelegramPost: false
        )
    }
    
    func loadImage(from doc: Document) async throws -> UIImage {
        guard let imageURLString = try extractImageURL(from: doc),
              let imageURL = URL(string: imageURLString) else {
            throw NewsParserError.imageLoadingFailed
        }
        
        let (imageData, _) = try await URLSession.shared.data(from: imageURL)
        
        guard let image = UIImage(data: imageData) else {
            throw NewsParserError.imageLoadingFailed
        }
        
        return image
    }
}
    
// MARK: - Extractors
private extension SputnikNewsService {
    
    func extractTitle(from doc: Document) throws -> String? {
        if let h1 = try doc.select("h1").first() {
            let text = try h1.text().trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                return text
            }
        }
        
        if let meta = try doc.select("meta[property=og:title]").first() {
            let content = try meta.attr("content").trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                return content
            }
        }
        
        return nil
    }
    
    func extractSubtitle(from doc: Document) throws -> String? {
        if let meta = try doc.select("meta[property=og:description]").first() {
            let content = try meta.attr("content").trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                return content
            }
        }
        
        if let meta = try doc.select("meta[name=description]").first() {
            let content = try meta.attr("content").trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                return content
            }
        }
        
        let paragraphs = try doc.select("p")
        
        for paragraph in paragraphs.array() {
            let text = try paragraph.text().trimmingCharacters(in: .whitespacesAndNewlines)
            if text.count > 40 {
                return text
            }
        }
        
        return nil
    }
    
    func extractDate(from doc: Document) throws -> String? {
        if let timeElement = try doc.select("time").first() {
            let text = try timeElement.text().trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                return text
            }
        }
        
        let bodyText = try doc.text()
        
        let fullDateRegex = try NSRegularExpression(
            pattern: #"(\d{1,2}:\d{2}\s+\d{1,2}\.\d{2}\.\d{4})"#
        )
        
        let range = NSRange(bodyText.startIndex..., in: bodyText)
        
        if let match = fullDateRegex.firstMatch(in: bodyText, range: range),
           let swiftRange = Range(match.range(at: 1), in: bodyText) {
            return String(bodyText[swiftRange])
        }
        
        return extractFirstTime(from: bodyText)
    }
    
    func extractImageURL(from doc: Document) throws -> String? {
        if let meta = try doc.select("meta[property=og:image]").first() {
            let content = try meta.attr("content").trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                return content
            }
        }
        
        if let image = try doc.select("img[src]").first() {
            let src = try image.attr("src").trimmingCharacters(in: .whitespacesAndNewlines)
            if !src.isEmpty {
                return src.hasPrefix("http") ? src : makeAbsoluteURL(from: src)
            }
        }
        
        return nil
    }
    
    func extractFirstTime(from text: String) -> String? {
        let regex = try? NSRegularExpression(pattern: #"\b\d{1,2}:\d{2}\b"#)
        let range = NSRange(text.startIndex..., in: text)
        
        guard let match = regex?.firstMatch(in: text, range: range),
              let swiftRange = Range(match.range, in: text) else {
            return nil
        }
        
        return String(text[swiftRange])
    }
}
