import UIKit

enum ContactsAssembly {
    static func build() -> UIViewController {
        let presenter: ContactsPresentationLogic = ContactsPresenter()
        let interactor: ContactsBusinessLogic = ContactsInteractor(presenter: presenter)
        
        let viewController: ContactsViewController = ContactsViewController(
            interactor: interactor
        )

        presenter.view = viewController
        
        return viewController
    }
}
