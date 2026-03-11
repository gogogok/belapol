import UIKit

final class  ContactsModel {
    
    enum LoadContactsView {
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
