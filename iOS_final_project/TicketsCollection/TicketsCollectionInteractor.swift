final class TicketsCollectionInteractor : TicketsCollectionBusinessLogic{
    
    var presenter: TicketsCollectionPresentationLogic
    private let repository = TicketsRepositoryService()
    
    init (presenter: TicketsCollectionPresentationLogic) {
        self.presenter = presenter
    }
    
    func loadView(request: Model.LoadView.Request) {
        presenter.presentView(response: Model.LoadView.Response(vc: request.vc))
    }
    
    func loadSaveTicket(request: Model.LoadAddTicket.Request) {
        repository.add(ticket: request.ticket)
    }
    
    func loadTickets(request: Model.LoadTicketsCollection.Request) {
        let pastTickets = repository.fetchPastTickets()
        let futureTickets = repository.fetchFutureTickets()
        presenter.presentTickets(response: Model.LoadTicketsCollection.Response(pastTickets: pastTickets, futureTickets: futureTickets))
    }
    
    func deleteTickets(request: Model.LoadAddTicket.Request) {
        repository.delete(request.ticket)
    }
    
    
}
