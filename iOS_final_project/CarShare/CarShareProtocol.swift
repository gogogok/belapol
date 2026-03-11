import Foundation

protocol CarShareBusinessLogic {
    typealias Model = CarShareModel
    
    func loadView(request: Model.LoadView.Request)
    
    func loadNotAnimatedView(request: Model.LoadView.Request)
}

protocol CarSharePresentationLogic: AnyObject {
    typealias Model = CarShareModel

    var view:  CarShareViewController? {get set}
    
    func presentView(response: Model.LoadView.Response)
    
    func presentNotAnimatedView(response: Model.LoadView.Response)
}


