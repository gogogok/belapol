final class ContactsInteractor : ContactsBusinessLogic{
    
    var presenter: ContactsPresentationLogic
    
    init (presenter: ContactsPresentationLogic) {
        self.presenter = presenter
    }
    
    func loadView(request: Model.LoadView.Request) {
        presenter.presentView(response: Model.LoadView.Response(vc: request.vc))
    }
}
