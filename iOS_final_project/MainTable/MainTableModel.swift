import UIKit

final class  MainTableModel {
    
    enum LoadMainTable {
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
    
    enum LoadArchiveData {
        struct Request {
            let view: UIView
            let request : ArchiveQueueScreenshotRequest
        }
        struct Response {
            let data: ArchiveQueueTableData
        }
        struct ViewModel {
            let data: ArchiveQueueTableData
        }
    }
    
    enum QueueDirection {
        case brestTerespol
        case berestovicaBobrovniki
    }

    struct BorderQueueInfo {
        let updatedAt: String
        let directionText: String
        let cars: String
        let buses: String
        let trucks: String
    }
    
    enum BorderQueueServiceError: Error {
        case invalidURL
        case invalidResponse
        case badStatusCode(Int)
        case emptyData
        case decodingFailed
        case queueBlockNotFound
    }
    
    struct ArchiveQueueScreenshotRequest {
        let checkpointName: String
        let date: String
    }
    
    enum ArchiveQueueScreenshotError: Error {
        case invalidURL
        case webViewMissing
        case formFillFailed
        case resultNotFound
        case parseFailed
    }
    
    struct ArchiveQueueTableData : Codable {
        let title: String
        let rows: [ArchiveQueueRow]
    }

    struct ArchiveQueueRow : Codable {
        let columns: [String]
    }

}
