//
//  TicketsService.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 7.03.26.
//

import Foundation
import UIKit

final class TicketsService {
    
    public func fetchTickets(searchData : SearchResultsResponse) -> [TicketsVM] {
        return mapToTicketsVM(from: searchData)
    }
    
    
    // MARK: - Step 2. Load trips
    
    public func loadSearchResults(
        searchId: String,
        fromId: Int,
        toId: Int,
        on date: String,
        passengers: Int,
        domainId: Int
    ) async throws -> SearchResultsResponse {
        
        var components = URLComponents(string: "https://busfor.by/api/v1/searches/\(searchId)")
        components?.queryItems = [
            URLQueryItem(name: "from_id", value: "\(fromId)"),
            URLQueryItem(name: "to_id", value: "\(toId)"),
            URLQueryItem(name: "on", value: date),
            URLQueryItem(name: "passengers", value: "\(passengers)"),
            URLQueryItem(name: "search", value: "true"),
            URLQueryItem(name: "domainId", value: "\(domainId)")
        ]
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.setValue("https://busfor.by", forHTTPHeaderField: "Referer")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse {
            print("Load trips status:", http.statusCode)
        }
        
        return try JSONDecoder().decode(SearchResultsResponse.self, from: data)
    }
    
    
    private func mapToTicketsVM(from response: SearchResultsResponse) -> [TicketsVM] {
        response.included
            .filter { $0.type == "trips" }
            .compactMap { item in
                guard let trip = item.attributes else { return nil }
                
                let title = trip.carrierName ?? trip.number ?? "-"
                //                let stationFrom = trip.startCityName ?? "Unknown"
                //                let stationTo = trip.endCityName ?? "Unknown"
                
                let fromStation = trip.startStation?.name ?? "-"
                let toStation = trip.endStation?.name ?? "-"
                let point = "\(fromStation) → \(toStation)"
                
                let date = formatDate(apiDate: trip.startDate) ?? "-"
                
                
                let startTime = trip.startTime ?? "--:--"
                let endTime = trip.endTime ?? "--:--"
                let time = "\(startTime) - \(endTime)"
                
                
                let grade = trip.carrierRating.map { String($0) } ?? "-"
                
                return TicketsVM(
                    title: title,
                    stationFrom: fromStation,
                    stationTo: toStation,
                    point: point,
                    date: date,
                    time: time,
                    image: UIImage(named: "cat_belapol")!,
                    grade: grade
                )
            }
    }
    
    func formatDate(apiDate: String?) -> String? {
        
        guard let apiDate else { return nil }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "ru_RU")
        
        guard let date = inputFormatter.date(from: apiDate) else {
            return apiDate
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Сегодня"
        }
        
        if calendar.isDateInTomorrow(date) {
            return "Завтра"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd.MM.yyyy"
        outputFormatter.locale = Locale(identifier: "ru_RU")
        
        return outputFormatter.string(from: date)
    }
}
