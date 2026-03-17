final class  AddTicketPresenter :  AddTicketPresentationLogic  {
    
    typealias Model = AddTicketModel
    
    weak var view: AddTicketViewController?
    
    func presentSavedTicket(response: Model.LoadAddTicket.Response) {
        view?.finishAddingTicket(vm: Model.LoadAddTicket.ViewModel(ticket: response.ticket))
    }
    
}
