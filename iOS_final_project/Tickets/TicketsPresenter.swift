final class  TicketsPresenter :  TicketsPresentationLogic  {
    
    typealias Model = TicketsModel
    
    weak var view: TicketsViewController?
    
    func presentView(response: Model.LoadView.Response) {
        self.view?.displayView(vc: response.vc)
    }
    
    func presentNotAnimatedView(response: Model.LoadView.Response) {
        self.view?.displayNotAnimatedView(vc: response.vc)
    }
    
    func presentTickets(response: Model.LoadTickets.Response) {
        self.view?.displayTickets(vm: Model.LoadTickets.ViewModel(hasError: response.hasError, loadedSections: response.loadedSections, fiterDara: response.fiterDara))
    }
    
    func presentSections(response: Model.LoadSections.Response) {
        self.view?.loadSections(vm: Model.LoadSections.ViewModel(section: response.section))
    }
}
