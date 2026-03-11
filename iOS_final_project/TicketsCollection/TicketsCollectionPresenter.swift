final class  TicketsCollectionPresenter :  TicketsCollectionPresentationLogic  {
    
    typealias Model = TicketsCollectionModel
    
    weak var view: TicketsCollectionViewController?
    
    func presentView(response: Model.LoadView.Response) {
        self.view?.displayView(vc: response.vc)
    }
    
}
