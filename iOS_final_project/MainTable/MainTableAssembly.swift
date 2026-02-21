import UIKit

enum MainTableAssembly {
    static func build() -> UIViewController {
        let presenter: MainTablePresentationLogic = MainTablePresenter()
        let interactor: MainTableBusinessLogic = MainTableInteractor(presenter: presenter)
        
        let viewController: MainTableViewController = MainTableViewController(
            interactor: interactor
        )

        presenter.view = viewController
        
        return viewController
    }
}
