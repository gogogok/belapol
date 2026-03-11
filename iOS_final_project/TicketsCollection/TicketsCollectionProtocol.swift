import Foundation

protocol TicketsCollectionBusinessLogic {
    typealias Model = TicketsCollectionModel
    
    func loadView(request: Model.LoadView.Request)
}

protocol TicketsCollectionPresentationLogic: AnyObject {
    typealias Model = TicketsCollectionModel

    var view:  TicketsCollectionViewController? {get set}
    
    func presentView(response: Model.LoadView.Response)
}


