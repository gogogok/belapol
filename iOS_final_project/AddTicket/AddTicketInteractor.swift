final class AddTicketInteractor : AddTicketBusinessLogic{
    
    var presenter: AddTicketPresentationLogic
    
    init (presenter: AddTicketPresentationLogic) {
        self.presenter = presenter
    }
    
}
