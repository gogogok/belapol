//
//  TicketsStruckts.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 6.03.26.
//
import UIKit

struct TicketsVM {
    let id: UUID
    let title: String
    let stationFrom: String
    let stationTo: String
    let point: String
    let date: String
    let time: String
    let image: UIImage?
    
    let ticketURL: String?
    let fromAddress: String?
    let toAddress: String?
}

extension TicketsVM {
    
    init(ticket: Ticket) {
        self.id = ticket.id ?? UUID()
        self.title = ticket.title ?? "-"
        self.stationFrom = ticket.stationFrom ?? "-"
        self.stationTo = ticket.stationTo ?? "-"
        self.point = ticket.point ?? "-"
        self.date = ticket.date ?? "-"
        self.time = ticket.time ?? "-"
        self.image = ImageMapping.image(bus: ticket.title!)
        self.ticketURL = ticket.ticketURL
        self.fromAddress = ticket.fromAddress
        self.toAddress = ticket.toAdress
    }
    
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
