import UIKit

final class MainTableInteractor : MainTableBusinessLogic{
   
    typealias Model = MainTableModel
    
    private var presenter: MainTablePresentationLogic
    private let dataService = ArchiveQueueDataService()
    
    init (presenter: MainTablePresentationLogic) {
        self.presenter = presenter
    }
    
    func loadView(request: Model.LoadView.Request) {
        presenter.presentView(response: Model.LoadView.Response(vc: request.vc))
    }
    
    func loadCalendarView(request: Model.LoadMainTable.Request) {
        presenter.presentCalendarView(response: Model.LoadMainTable.Response())
    }
    
    func loadArchiveData(request: Model.LoadArchiveData.Request) {
        dataService.loadData(in: request.view, request: request.request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("Таблица получена")
                    self?.presenter.presentArchiveData(response: Model.LoadArchiveData.Response(data: data))
                case .failure(let error):
                    print("Ошибка загрузки архива: \(error)")
                }
            }
        }
    }
}
