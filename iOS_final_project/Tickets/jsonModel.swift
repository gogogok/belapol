//
//  jsonModel.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 7.03.26.
//

import Foundation

struct CreateSearchResponse: Decodable {
    let data: SearchData
}

struct SearchData: Decodable {
    let id: String
}

struct SearchResultsResponse: Decodable {
    let included: [IncludedItem]
}

struct IncludedItem: Decodable {
    let id: String?
    let type: String
    let attributes: TripAttributes?
}

struct TripAttributes: Decodable {
    let startDate: String?
    let startTime: String?
    let endDate: String?
    let endTime: String?
    let startCityName: String?
    let endCityName: String?
    let startStation: Station?
    let endStation: Station?
    let number: String?
    let carrierRating: String?
    let carrierName: String?
    
    enum CodingKeys: String, CodingKey {
        case startDate = "start-date"
        case startTime = "start-time"
        case endDate = "end-date"
        case endTime = "end-time"
        case startCityName = "start-city-name"
        case endCityName = "end-city-name"
        case startStation = "start-station"
        case endStation = "end-station"
        case number
        case carrierRating = "carrier-rating"
        case carrierName = "carrier-name"
    }
}

struct Station: Decodable {
    let name: String?
    let address: String?
}
