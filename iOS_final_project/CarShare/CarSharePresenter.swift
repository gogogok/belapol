final class  CarSharePresenter :  CarSharePresentationLogic  {
    
    typealias Model = CarShareModel
    
    weak var view: CarShareViewController?
    
    func presentView(response: Model.LoadView.Response) {
        self.view?.displayView(vc: response.vc)
    }
    
    func presentNotAnimatedView(response: Model.LoadView.Response) {
        self.view?.displayNotAnimatedView(vc: response.vc)
    }
    
    
}
