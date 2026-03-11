import UIKit

enum NewsAssembly {
    static func build() -> UIViewController {
        let presenter: NewsPresentationLogic = NewsPresenter()
        let interactor: NewsBusinessLogic = NewsInteractor(presenter: presenter)
        
        let viewController: NewsViewController = NewsViewController(
            interactor: interactor
        )

        presenter.view = viewController
        
        return viewController
    }
}
