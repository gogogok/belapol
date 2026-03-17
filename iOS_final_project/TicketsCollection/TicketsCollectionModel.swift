import UIKit

final class  TicketsCollectionModel {
    
    enum LoadTicketsCollection {
        struct Request {}
        struct Response {
            var pastTickets: [TicketsVM]
            var futureTickets: [TicketsVM]
        }
        struct ViewModel {
            var pastTickets: [TicketsVM]
            var futureTickets: [TicketsVM]
        }
    }

    enum LoadView {
        struct Request {
            var vc : UIViewController
        }
        struct Response {
            var vc : UIViewController
        }
        struct ViewModel {}
    }
    
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
