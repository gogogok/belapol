import UIKit

final class TicketsInteractor : TicketsBusinessLogic{
    
    // MARK: - Constants
    private enum Constants {
        static let minskId = 4102
        static let warsawId = 3465
        static let defaultPassengers = 1
        static let defaultDomainId = 10
        static let defaultSectionTitle = "Найденные билеты"
    }
    
    private var presenter: TicketsPresentationLogic
    private let service = TicketsService()
    
    init (presenter: TicketsPresentationLogic) {
        self.presenter = presenter
    }
    
    func loadView(request: Model.LoadView.Request) {
        presenter.presentView(response: Model.LoadView.Response(vc: request.vc))
    }
    
    func loadNotAnimatedView(request: Model.LoadView.Request) {
        presenter.presentNotAnimatedView(response: Model.LoadView.Response(vc: request.vc))
    }
    
    func loadTickets(request: Model.LoadTickets.Request) {
        let filterData = request.filterData
        Task {
            do {
                let date = formatRequestDate(filterData.date) ?? defaultRequestDate()
                
                let departure = filterData.departurePlace?.trimmingCharacters(in: .whitespacesAndNewlines)
                let arrival = filterData.arrivalPlace?.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let loadedSections: [TicketsSectionVM]
                
                if let departure,
                   let arrival,
                   let fromId = mapCityToId(departure),
                   let toId = mapCityToId(arrival) {
                    
                    let title = "\(departure) → \(arrival) | Билеты на автобус"
                    
                    let section = try await loadRouteSection(
                        title: title,
                        fromId: fromId,
                        toId: toId,
                        date: date,
                        filterData: filterData
                    )
                    
                    loadedSections = [section]
                } else {
                    async let minskWarsaw = loadRouteSection(
                        title: "Минск → Варшава | Билеты на автобус",
                        fromId: Constants.minskId,
                        toId: Constants.warsawId,
                        date: date,
                        filterData: filterData
                    )
                    
                    async let warsawMinsk = loadRouteSection(
                        title: "Варшава → Минск | Билеты на автобус",
                        fromId: Constants.warsawId,
                        toId: Constants.minskId,
                        date: date,
                        filterData: filterData
                    )
                    
                    loadedSections = try await [minskWarsaw, warsawMinsk]
                }
                
                presenter.presentTickets(response: Model.LoadTickets.Response(hasError: false, loadedSections: loadedSections, fiterDara: filterData))
            } catch {
                presenter.presentTickets(response: Model.LoadTickets.Response(hasError: true, loadedSections: [], fiterDara: filterData))
            }
        }
        
    }
    
    func loadSections(request: Model.LoadSections.Request) async {
        print("START section:", request.title,)
        
        do {
            let section = try await loadRouteSection(
                title: request.title,
                fromId: request.fromId,
                toId: request.toId,
                date: request.date,
                filterData: request.filterData
            )
            
            print("SUCCESS section:", request.title, "items:", section.items.count)
            presenter.presentSections(response: Model.LoadSections.Response(section: section))
        } catch {
            print("FAILED section:", request.title)
            print("ERROR:", error.localizedDescription)
            print("FULL ERROR:", error)
            
            let failedSection = TicketsSectionVM(
                title: request.title,
                items: []
            )
            presenter.presentSections(response: Model.LoadSections.Response(section: failedSection))
        }
    }
    
    
    //MARK: - Help Methods
    private func formatRequestDate(_ date: Date?) -> String? {
        guard let date else { return nil }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func defaultRequestDate() -> String {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return formatRequestDate(tomorrow) ?? "2026-03-18"
    }
    
    private func loadRouteSection(
        title: String,
        fromId: Int,
        toId: Int,
        date: String,
        filterData: TicketFilterPanelView.FilterData? = nil
    ) async throws -> TicketsSectionVM {
        
        let loader = BusforHiddenLoader()
        
        let hiddenResult = try await loader.load(
            fromId: fromId,
            toId: toId,
            date: date,
            passengers: Constants.defaultPassengers
        )
        
        guard let searchId = hiddenResult.searchId else {
            throw NSError(
                domain: "BusforHiddenLoader",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Search ID not found"]
            )
        }
        
        print("Loading route:", fromId, "->", toId, "date:", date)
        print("Hidden searchId:", hiddenResult.searchId ?? "nil")
        print("API urls:", hiddenResult.apiUrls)
        
        let searchResponse = try await service.loadSearchResults(
            searchId: searchId,
            fromId: fromId,
            toId: toId,
            on: date,
            passengers: Constants.defaultPassengers,
            domainId: Constants.defaultDomainId
        )
        
        print("Included count:", searchResponse.included.count)
        
        var items = service.fetchTickets(searchData: searchResponse, checkoutURL: hiddenResult.checkoutUrl)
        
        if let filterData {
            items = filterTicketsByTime(items, filter: filterData)
        }
        print("Trips count:", items.count)
        
        return TicketsSectionVM(title: title, items: items)
    }
    
    private func mapCityToId(_ city: String?) -> Int? {
        guard let city = city?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased(),
              !city.isEmpty else {
            return nil
        }
        
        switch city {
        case "минск":
            return 4102
        case "варшава":
            return 3465
        default:
            return nil
        }
    }
    
    private func filterTicketsByTime(
        _ items: [TicketsVM],
        filter: TicketFilterPanelView.FilterData
    ) -> [TicketsVM] {
        items.filter { item in
            guard let itemStartTime = extractStartTime(from: item.time) else {
                return false
            }
            
            var isMatched = true
            
            if let fromTime = filter.departureTimeFrom {
                isMatched = isMatched && compareTime(itemStartTime, isGreaterOrEqualThan: fromTime)
            }
            
            if let toTime = filter.departureTimeTo {
                isMatched = isMatched && compareTime(itemStartTime, isLessOrEqualThan: toTime)
            }
            
            return isMatched
        }
        
    }
    
    private func extractStartTime(from timeString: String) -> Date? {
        let cleaned = timeString.replacingOccurrences(of: "\n", with: " ")
        let parts = cleaned.components(separatedBy: "-")
        
        guard let firstPart = parts.first?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !firstPart.isEmpty else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: firstPart)
    }
    
    private func compareTime(_ lhs: Date, isGreaterOrEqualThan rhs: Date) -> Bool {
        let calendar = Calendar.current
        let lhsComponents = calendar.dateComponents([.hour, .minute], from: lhs)
        let rhsComponents = calendar.dateComponents([.hour, .minute], from: rhs)
        
        guard let lhsHour = lhsComponents.hour,
              let lhsMinute = lhsComponents.minute,
              let rhsHour = rhsComponents.hour,
              let rhsMinute = rhsComponents.minute else {
            return false
        }
        
        if lhsHour > rhsHour { return true }
        if lhsHour < rhsHour { return false }
        return lhsMinute >= rhsMinute
    }
    
    private func compareTime(_ lhs: Date, isLessOrEqualThan rhs: Date) -> Bool {
        let calendar = Calendar.current
        let lhsComponents = calendar.dateComponents([.hour, .minute], from: lhs)
        let rhsComponents = calendar.dateComponents([.hour, .minute], from: rhs)
        
        guard let lhsHour = lhsComponents.hour,
              let lhsMinute = lhsComponents.minute,
              let rhsHour = rhsComponents.hour,
              let rhsMinute = rhsComponents.minute else {
            return false
        }
        
        if lhsHour < rhsHour { return true }
        if lhsHour > rhsHour { return false }
        return lhsMinute <= rhsMinute
    }
}
