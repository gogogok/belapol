import Foundation
import UIKit

protocol MainTableBusinessLogic {
    typealias Model = MainTableModel
    
    func loadCalendarView(request: Model.LoadMainTable.Request)
}

protocol MainTablePresentationLogic: AnyObject {
    typealias Model = MainTableModel

    var view:  MainTableViewController? {get set}
    
    func presentCalendarView(response: Model.LoadMainTable.Response)
}


