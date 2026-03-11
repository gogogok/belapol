import UIKit

enum TicketsAssembly {
    static func build() -> UIViewController {
        let presenter: TicketsPresentationLogic = TicketsPresenter()
        let interactor: TicketsBusinessLogic = TicketsInteractor(presenter: presenter)
        
        let viewController: TicketsViewController = TicketsViewController(
            interactor: interactor
        )

        presenter.view = viewController
        
        return viewController
    }
}
