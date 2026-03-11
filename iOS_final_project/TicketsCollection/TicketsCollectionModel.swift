import UIKit

final class  TicketsCollectionModel {
    
    enum LoadTicketsCollection {
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
