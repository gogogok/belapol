final class  TicketsCollectionPresenter :  TicketsCollectionPresentationLogic  {
    
    
    typealias Model = TicketsCollectionModel
    
    weak var view: TicketsCollectionViewController?
    
    func presentView(response: Model.LoadView.Response) {
        self.view?.displayView(vc: response.vc)
    }
    
    func presentTickets(response: Model.LoadTicketsCollection.Response) {
        self.view?.setupData(vm: Model.LoadTicketsCollection.ViewModel(pastTickets: response.pastTickets, futureTickets: response.futureTickets))
    }
    
}
