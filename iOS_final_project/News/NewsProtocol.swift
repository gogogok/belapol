import Foundation

protocol NewsBusinessLogic {
    typealias Model = NewsModel
    
    func loadView(request: Model.LoadView.Request)

}

protocol NewsPresentationLogic: AnyObject {
    typealias Model = NewsModel

    var view:  NewsViewController? {get set}
    
    func presentView(response: Model.LoadView.Response)
}

