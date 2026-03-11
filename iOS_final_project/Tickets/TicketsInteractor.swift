final class TicketsInteractor : TicketsBusinessLogic{
    
    var presenter: TicketsPresentationLogic
    
    init (presenter: TicketsPresentationLogic) {
        self.presenter = presenter
    }
    
    func loadView(request: Model.LoadView.Request) {
        presenter.presentView(response: Model.LoadView.Response(vc: request.vc))
    }
    
    func loadNotAnimatedView(request: Model.LoadView.Request) {
        presenter.presentNotAnimatedView(response: Model.LoadView.Response(vc: request.vc))
    }
    
}
