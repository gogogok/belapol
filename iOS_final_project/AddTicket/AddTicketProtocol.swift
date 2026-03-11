import Foundation

protocol AddTicketBusinessLogic {
    typealias Model = AddTicketModel
}

protocol AddTicketPresentationLogic: AnyObject {
    typealias Model = AddTicketModel

    var view:  AddTicketViewController? {get set}
}


