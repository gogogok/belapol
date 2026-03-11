import UIKit

final class  CarShareModel {
    
    enum LoadCarShare {
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
