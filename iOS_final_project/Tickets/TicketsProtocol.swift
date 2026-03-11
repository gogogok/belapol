import Foundation

protocol TicketsBusinessLogic {
    typealias Model = TicketsModel
    
    func loadView(request: Model.LoadView.Request)
    
    func loadNotAnimatedView(request: Model.LoadView.Request)
}

protocol TicketsPresentationLogic: AnyObject {
    typealias Model = TicketsModel

    var view:  TicketsViewController? {get set}
    
    func presentView(response: Model.LoadView.Response)
    
    func presentNotAnimatedView(response: Model.LoadView.Response)
}


