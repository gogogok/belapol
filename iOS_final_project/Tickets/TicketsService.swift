//
//  TicketsService.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 7.03.26.
//

import Foundation
import UIKit

final class TicketsService {
    
    private var rawIncluded : [[String: Any]] = []
    
    public func fetchTickets(
        searchData: SearchResultsResponse,
        checkoutURL: String
    ) -> [TicketsVM] {
        return mapToTicketsVM(from: searchData, checkoutUrl: checkoutURL)
    }
    
    
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
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let included = json["included"] as? [[String: Any]] {
            self.rawIncluded = included
        } else {
            self.rawIncluded = []
        }
        
        return try JSONDecoder().decode(SearchResultsResponse.self, from: data)
    }
    
    
    private func mapToTicketsVM(
        from response: SearchResultsResponse,
        checkoutUrl: String
    ) -> [TicketsVM] {
        let trips = response.included.filter { $0.type == "trips" }

        var uniqueTrips: [TicketsVM] = []
        var seenKeys = Set<String>()

        for item in trips {

            guard let trip = item.attributes else { continue }

            guard let carrier = trip.carrierName else { continue }
            guard let start = trip.startTime else { continue }
            guard let end = trip.endTime else { continue }
            guard let from = trip.startStation?.name else { continue }
            guard let to = trip.endStation?.name else { continue }


            let title = carrier
            let fromCityName = from
            let toCityName = to
            guard let fromStation = trip.startStation?.address else { continue }
            guard let toStation = trip.endStation?.address else { continue }
            
            let key = "\(carrier)_\(start)_\(end)_\(from)_\(to)"

            if seenKeys.contains(key) {
                continue
            }

            seenKeys.insert(key)

            let borderPoint = lastBYBorderPoint(tripId: item.id)
            let point = borderPoint.map { "* через \($0)" } ?? " "

            let date = formatDate(apiDate: trip.startDate) ?? "-"
            let time = "\(start) - \(end)"

            let ticketURL = URL(string: checkoutUrl)

            uniqueTrips.append(
                TicketsVM(
                    id: UUID(),
                    title: title,
                    stationFrom: fromCityName,
                    stationTo: toCityName,
                    point: point,
                    date: date,
                    time: time,
                    image: ImageMapping.image(bus: title),
                    ticketURL: ticketURL?.absoluteString,
                    fromAddress: fromStation,
                    toAddress: toStation
                )
            )
        }

        return uniqueTrips
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
    
    private func lastBYBorderPoint(tripId: String?) -> String? {
        guard let tripId else { return nil }
        
        guard let tripObject = rawIncluded.first(where: {
            ($0["id"] as? String) == tripId && ($0["type"] as? String) == "trips"
        }) else {
            return nil
        }
        
        guard
            let relationships = tripObject["relationships"] as? [String: Any],
            let points = relationships["points"] as? [String: Any],
            let data = points["data"] as? [[String: Any]]
        else {
            return nil
        }
        
        let pointIds: [String] = data.compactMap { $0["id"] as? String }
        
        let tripPoints: [[String: Any]] = pointIds.compactMap { pointId in
            rawIncluded.first(where: {
                ($0["id"] as? String) == pointId && ($0["type"] as? String) == "trip-points"
            })
        }
        
        func pointText(_ point: [String: Any]) -> String {
            let attributes = point["attributes"] as? [String: Any]
            
            let title = attributes?["title"] as? String ?? ""
            let description = attributes?["description"] as? String ?? ""
            let address = attributes?["address"] as? String ?? ""
            
            return "\(title) \(description) \(address)".lowercased()
        }
        
        if tripPoints.last(where: { pointText($0).contains("берестовиц") }) != nil {
            return "Берестовицу"
        }
        
        if tripPoints.last(where: { pointText($0).contains("брест") }) != nil {
            return "Брест"
        }
        
        return "Литву"
    }
}
