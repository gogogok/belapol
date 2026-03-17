import Foundation

protocol TicketsCollectionBusinessLogic {
    typealias Model = TicketsCollectionModel
    
    func loadView(request: Model.LoadView.Request)
    
    func loadSaveTicket(request: Model.LoadAddTicket.Request)
    
    func loadTickets(request: Model.LoadTicketsCollection.Request)
    
    func deleteTickets(request: Model.LoadAddTicket.Request)
}

protocol TicketsCollectionPresentationLogic: AnyObject {
    typealias Model = TicketsCollectionModel

    var view:  TicketsCollectionViewController? {get set}
    
    func presentView(response: Model.LoadView.Response)
    
    func presentTickets(response: Model.LoadTicketsCollection.Response)
    
}


