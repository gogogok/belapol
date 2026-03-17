final class  NewsPresenter :  NewsPresentationLogic  {

    typealias Model = NewsModel
    
    weak var view: NewsViewController?
    
    func presentView(response: Model.LoadView.Response) {
        self.view?.displayView(vc: response.vc)
    }
    
    func presentNews(response: Model.LoadPosts.Response) {
        self.view?.presentLoadedNews(vm: Model.LoadPosts.ViewModel(news: response.news))
    }
    
}
