final class TicketsCollectionInteractor : TicketsCollectionBusinessLogic{
    
    var presenter: TicketsCollectionPresentationLogic
    
    init (presenter: TicketsCollectionPresentationLogic) {
        self.presenter = presenter
    }
    
    func loadView(request: Model.LoadView.Request) {
        presenter.presentView(response: Model.LoadView.Response(vc: request.vc))
    }
    
}
