import CoreData
import UIKit

final class TicketsRepositoryWorker {
    private let ctx = Persistence.shared.container.viewContext
    
    func fetchAll() throws -> [TicketsVM] {
        let req: NSFetchRequest<Ticket> = Ticket.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return try ticketsToTicketsVM(ctx.fetch(req))
    }
    
    func fetchPastTickets() throws -> [TicketsVM] {
        let tickets = try fetchAll()
        let today = Calendar.current.startOfDay(for: Date())
        
        return tickets.filter {
            guard let date = dateFormatter.date(from: $0.date) else { return false }
            return date < today
        }
    }
    
    func fetchFutureTickets() throws -> [TicketsVM] {
        let tickets = try fetchAll()
        let today = Calendar.current.startOfDay(for: Date())
        
        return tickets.filter {
            guard let date = dateFormatter.date(from: $0.date) else { return false }
            return date >= today
        }
    }
    
    func add(ticket: TicketsVM) {
        let ticketEntity = Ticket(context: ctx)
        ticketEntity.id = ticket.id
        ticketEntity.title = ticket.title
        ticketEntity.stationFrom = ticket.stationFrom
        ticketEntity.stationTo = ticket.stationTo
        ticketEntity.date = ticket.date
        ticketEntity.point = ticket.point
        ticketEntity.time = ticket.time
        ticketEntity.image = ticket.image?.accessibilityIdentifier ?? ""
        
        Persistence.shared.save()
    }
    
    func clearAll() {
        let request: NSFetchRequest<NSFetchRequestResult> = Ticket.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try ctx.execute(deleteRequest)
            try ctx.save()
        } catch {
            print("Ошибка очистки CoreData:", error)
        }
    }
    
    func delete(id: UUID) {
        let request: NSFetchRequest<Ticket> = Ticket.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let ticket = try ctx.fetch(request).first {
                ctx.delete(ticket)
                try ctx.save()
                ctx.refreshAllObjects()
            }
        } catch {
            print("Ошибка удаления билета: \(error)")
        }
    }
    
    private func ticketsToTicketsVM(_ tickets: [Ticket]) -> [TicketsVM] {
        var ticketsVM: [TicketsVM] = []
        for ticket in tickets {
            ticketsVM.append(TicketsVM(id: ticket.id ?? UUID(),
                                       title: ticket.title ?? "-",
                                       stationFrom: ticket.stationFrom ?? "-",
                                       stationTo: ticket.stationTo ?? "-",
                                       point: ticket.point ?? "-",
                                       date: ticket.date ?? "-",
                                       time: ticket.time ?? "-",
                                       image: ImageMapping.image(bus: ticket.title ?? "-"),
                                       ticketURL: ticket.ticketURL,
                                       fromAddress: ticket.fromAddress,
                                       toAddress: ticket.toAdress))
        }
        return ticketsVM
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// MARK: - обёртка над репозиторием
final class TicketsRepositoryService {
    private let repo = TicketsRepositoryWorker()
    private let ctx = Persistence.shared.container.viewContext
    
    func fetchAll() -> [TicketsVM] { (try? repo.fetchAll()) ?? [] }
    func add(ticket: TicketsVM) { repo.add(ticket: ticket) }
    func delete(_ ticket: TicketsVM) { repo.delete(id: ticket.id) }
    func fetchPastTickets() -> [TicketsVM] {
        (try? repo.fetchPastTickets()) ?? []
    }
    func fetchFutureTickets() -> [TicketsVM] {
        (try? repo.fetchFutureTickets()) ?? []
    }
}

