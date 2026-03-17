import Foundation

protocol NewsBusinessLogic {
    typealias Model = NewsModel
    
    func loadView(request: Model.LoadView.Request)
    
    func loadNews(request: Model.LoadPosts.Request)

}

protocol NewsPresentationLogic: AnyObject {
    typealias Model = NewsModel

    var view:  NewsViewController? {get set}
    
    func presentView(response: Model.LoadView.Response)
    
    func presentNews(response: Model.LoadPosts.Response)
}

