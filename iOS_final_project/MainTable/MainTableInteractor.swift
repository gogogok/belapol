final class MainTableInteractor : MainTableBusinessLogic{
    
    typealias Model = MainTableModel
    
    var presenter: MainTablePresentationLogic
    
    init (presenter: MainTablePresentationLogic) {
        self.presenter = presenter
    }
    
    func loadCalendarView(request: Model.LoadMainTable.Request) {
        presenter.presentCalendarView(response: Model.LoadMainTable.Response())
    }
}
