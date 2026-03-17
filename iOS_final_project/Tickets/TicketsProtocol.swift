import Foundation

protocol TicketsBusinessLogic {
    typealias Model = TicketsModel
    
    func loadView(request: Model.LoadView.Request)
    
    func loadNotAnimatedView(request: Model.LoadView.Request)
    
    func loadTickets(request: Model.LoadTickets.Request)
    
    func loadSections(request: Model.LoadSections.Request) async
}

protocol TicketsPresentationLogic: AnyObject {
    typealias Model = TicketsModel

    var view:  TicketsViewController? {get set}
    
    func presentView(response: Model.LoadView.Response)
    
    func presentNotAnimatedView(response: Model.LoadView.Response)
    
    func presentTickets(response: Model.LoadTickets.Response)
    
    func presentSections(response: Model.LoadSections.Response)
}


