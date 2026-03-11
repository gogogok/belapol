import Foundation
import UIKit

protocol MainTableBusinessLogic {
    typealias Model = MainTableModel
    
    func loadView(request: Model.LoadView.Request)
    
    func loadCalendarView(request: Model.LoadMainTable.Request)
}

protocol MainTablePresentationLogic: AnyObject {
    typealias Model = MainTableModel

    var view:  MainTableViewController? {get set}
    
    func presentView(response: Model.LoadView.Response)
    
    func presentCalendarView(response: Model.LoadMainTable.Response)
}

protocol BorderQueueServiceProtocol {
    typealias Model = MainTableModel
    
    func fetchQueue(point: String) async throws -> Model.BorderQueueInfo
}

