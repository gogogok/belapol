final class  NewsPresenter :  NewsPresentationLogic  {
   
    typealias Model = NewsModel
    
    weak var view: NewsViewController?
    
    func presentView(response: Model.LoadView.Response) {
        self.view?.displayView(vc: response.vc)
    }
    
}
