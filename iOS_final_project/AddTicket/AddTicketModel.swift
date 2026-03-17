import UIKit

final class  AddTicketModel {
    
    enum LoadAddTicket {
        struct Request {
            var ticket: TicketsVM
        }
        struct Response {
            var ticket: TicketsVM
        }
        struct ViewModel {
            var ticket: TicketsVM
        }
    }

}
