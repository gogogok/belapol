import UIKit

final class  NewsModel {
    
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
            var news: [NewsVM]
        }
        struct ViewModel {
            var news: [NewsVM]
        }
    }
    
    struct NewsVM {
        let title: String
        let dateText: String
        let subtitle: String
        let image: UIImage?
        let url: URL?
        let isTelegramPost: Bool
    }
    
    struct BorderResponse: Decodable {
        let posts: [BorderPost]
    }

    struct BorderPost: Decodable {
        let id: Int
        let title: String
        let description: String
        let image: String
        let date: String
    }

}
