import Foundation

protocol AddTicketBusinessLogic {
    typealias Model = AddTicketModel
    
    func loadSaveTicket(request: Model.LoadAddTicket.Request)
}

protocol AddTicketPresentationLogic: AnyObject {
    typealias Model = AddTicketModel

    var view:  AddTicketViewController? {get set}
    
    func presentSavedTicket(response: Model.LoadAddTicket.Response)

}


