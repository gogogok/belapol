import Foundation

final class BorderQueueService: BorderQueueServiceProtocol {
    
    typealias Model = MainTableModel
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchQueue(point: String) async throws -> Model.BorderQueueInfo {
        guard let url = URL(string: "https://gpk.gov.by/situation-at-the-border/punkty-propuska/\(point)/") else {
            throw Model.BorderQueueServiceError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Model.BorderQueueServiceError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw Model.BorderQueueServiceError.badStatusCode(httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw Model.BorderQueueServiceError.emptyData
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw Model.BorderQueueServiceError.decodingFailed
        }
        
        return try parseQueue(from: html)
    }
    
    private func parseQueue(from html: String) throws -> Model.BorderQueueInfo {
        let text = normalizedText(from: html)
        
        let pattern = """
        Информация\\s+об\\s+очередях\\s+в\\s+пункте\\s+пропуска\\s+
        (\\d{2}\\.\\d{2}\\.\\d{4}\\s+\\d{2}:\\d{2})\\s+
        Архив\\s+очередей\\s+
        (выезд\\s+из\\s+РБ)\\s+
        ([\\d-]+)\\s+
        ([\\d-]+)\\s+
        ([\\d-]+)
        """
        
        let regex = try NSRegularExpression(
            pattern: pattern,
            options: [.allowCommentsAndWhitespace, .caseInsensitive]
        )
        
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        
        guard let match = regex.firstMatch(in: text, options: [], range: nsRange),
              let updatedAtRange = Range(match.range(at: 1), in: text),
              let directionRange = Range(match.range(at: 2), in: text),
              let carsRange = Range(match.range(at: 3), in: text),
              let busesRange = Range(match.range(at: 4), in: text),
              let trucksRange = Range(match.range(at: 5), in: text) else {
            throw Model.BorderQueueServiceError.queueBlockNotFound
        }
        
        return Model.BorderQueueInfo(
            updatedAt: String(text[updatedAtRange]),
            directionText: String(text[directionRange]),
            cars: String(text[carsRange]),
            buses: String(text[busesRange]),
            trucks: String(text[trucksRange])
        )
    }
    
    private func normalizedText(from html: String) -> String {
        var text = html
        
        text = text.replacingOccurrences(of: "<script[\\s\\S]*?</script>", with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: "<style[\\s\\S]*?</style>", with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
