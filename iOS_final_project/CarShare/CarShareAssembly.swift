import UIKit

enum CarShareAssembly {
    static func build() -> UIViewController {
        let presenter: CarSharePresentationLogic = CarSharePresenter()
        let interactor: CarShareBusinessLogic = CarShareInteractor(presenter: presenter)
        
        let viewController: CarShareViewController = CarShareViewController(
            interactor: interactor
        )

        presenter.view = viewController
        
        return viewController
    }
}
