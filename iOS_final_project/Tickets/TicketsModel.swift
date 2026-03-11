import UIKit

final class  TicketsModel {
    
    enum LoadTickets {
        struct Request {}
        struct Response {}
        struct ViewModel {}
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

}
