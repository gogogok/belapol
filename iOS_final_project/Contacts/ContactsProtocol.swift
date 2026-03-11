import Foundation

protocol ContactsBusinessLogic {
    typealias Model = ContactsModel
    
    func loadView(request: Model.LoadView.Request)
    
}

protocol ContactsPresentationLogic: AnyObject {
    typealias Model = ContactsModel

    var view:  ContactsViewController? {get set}
    
    func presentView(response: Model.LoadView.Response)
}


