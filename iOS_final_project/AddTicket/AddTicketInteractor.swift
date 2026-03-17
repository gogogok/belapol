final class AddTicketInteractor : AddTicketBusinessLogic{
    
    var presenter: AddTicketPresentationLogic
    
    init (presenter: AddTicketPresentationLogic) {
        self.presenter = presenter
    }
    
    func loadSaveTicket(request: Model.LoadAddTicket.Request) {
        self.presenter.presentSavedTicket(response: Model.LoadAddTicket.Response(ticket: request.ticket))
    }
    
}
