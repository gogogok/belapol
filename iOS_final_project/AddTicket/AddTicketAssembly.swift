import UIKit

enum AddTicketAssembly {
    static func build() -> UIViewController {
        let presenter: AddTicketPresentationLogic = AddTicketPresenter()
        let interactor: AddTicketBusinessLogic = AddTicketInteractor(presenter: presenter)
        
        let viewController: AddTicketViewController = AddTicketViewController(
            interactor: interactor
        )

        presenter.view = viewController
        
        return viewController
    }
}
