final class  ContactsPresenter :  ContactsPresentationLogic  {
    
    typealias Model = ContactsModel
    
    weak var view: ContactsViewController?
    
    func presentView(response: Model.LoadView.Response) {
        self.view?.displayView(vc: response.vc)
    }
    
    
}
