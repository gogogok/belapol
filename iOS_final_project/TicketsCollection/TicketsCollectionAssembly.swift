import UIKit

enum TicketsCollectionAssembly {
    static func build() -> UIViewController {
        let presenter: TicketsCollectionPresentationLogic = TicketsCollectionPresenter()
        let interactor: TicketsCollectionBusinessLogic = TicketsCollectionInteractor(presenter: presenter)
        
        let viewController: TicketsCollectionViewController = TicketsCollectionViewController(
            interactor: interactor
        )

        presenter.view = viewController
        
        return viewController
    }
}
