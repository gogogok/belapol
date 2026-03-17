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
    
    enum LoadPosts {
        struct Request {
            var vc : UIViewController
        }
        struct Response {
            var vc : UIViewController
            var sections : [AutoSectionVM]
        }
        struct ViewModel {
            var sections : [AutoSectionVM]
        }
    }
    
    struct CarPostDTO: Decodable {
        let date: String
        let time: String
        let description: String
        let userName: String
        let nickname: String
        let direction: String
    }
    
    struct CarPostsResponseDTO: Decodable {
        let posts: [CarPostDTO]
    }

}
