final class  TicketsPresenter :  TicketsPresentationLogic  {
    
    typealias Model = TicketsModel
    
    weak var view: TicketsViewController?
    
    func presentView(response: Model.LoadView.Response) {
        self.view?.displayView(vc: response.vc)
    }
    
    func presentNotAnimatedView(response: Model.LoadView.Response) {
        self.view?.displayNotAnimatedView(vc: response.vc)
    }
}
