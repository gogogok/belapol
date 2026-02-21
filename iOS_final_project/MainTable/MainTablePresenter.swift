final class  MainTablePresenter :  MainTablePresentationLogic  {
    
    typealias Model = MainTableModel
    
    weak var view: MainTableViewController?
    
    func presentCalendarView(response: Model.LoadMainTable.Response) {
        view!.presentCalendarSheet()
    }
}
