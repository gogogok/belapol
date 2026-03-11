final class NewsInteractor : NewsBusinessLogic{
    
    var presenter: NewsPresentationLogic
    
    init (presenter: NewsPresentationLogic) {
        self.presenter = presenter
    }
    
    func loadView(request: Model.LoadView.Request) {
        presenter.presentView(response: Model.LoadView.Response(vc: request.vc))
    }
    
}
