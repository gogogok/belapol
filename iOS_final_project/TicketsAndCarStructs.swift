//
//  TicketsStruckts.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 6.03.26.
//
import UIKit

struct TicketsVM {
    let title: String
    let stationFrom: String
    let stationTo: String
    let point: String
    let date: String
    let time: String
    let image: UIImage
    let grade: String
}

struct TicketsSectionVM {
    let title: String
    let items: [TicketsVM]
}

struct CarVM {
    let date: String
    let time: String
    let description: String
    let userName: String
    let nickname: String
}

struct AutoSectionVM {
    let title: String
    let items: [CarVM]
}
