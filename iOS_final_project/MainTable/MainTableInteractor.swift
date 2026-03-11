final class MainTableInteractor : MainTableBusinessLogic{

    typealias Model = MainTableModel
    
    var presenter: MainTablePresentationLogic
    
    init (presenter: MainTablePresentationLogic) {
        self.presenter = presenter
    }
    
    func loadView(request: Model.LoadView.Request) {
        presenter.presentView(response: Model.LoadView.Response(vc: request.vc))
    }
    
    func loadCalendarView(request: Model.LoadMainTable.Request) {
        presenter.presentCalendarView(response: Model.LoadMainTable.Response())
    }
}
