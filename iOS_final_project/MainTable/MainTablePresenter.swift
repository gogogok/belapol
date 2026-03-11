import UIKit

final class  MainTablePresenter :  MainTablePresentationLogic  {
    
    typealias Model = MainTableModel
    
    weak var view: MainTableViewController?
    
    
    func presentView(response: Model.LoadView.Response) {
        self.view?.displayView(vc: response.vc)
    }
    
    
    func presentCalendarView(response: Model.LoadMainTable.Response) {
        view!.presentCalendarSheet()
    }
}
