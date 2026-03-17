import UIKit

final class  TicketsModel {
    
    enum LoadTickets {
        struct Request {
            var filterData: TicketFilterPanelView.FilterData
        }
        struct Response {
            var hasError: Bool
            var loadedSections: [TicketsSectionVM]
            var fiterDara: TicketFilterPanelView.FilterData
        }
        struct ViewModel {
            var hasError: Bool
            var loadedSections: [TicketsSectionVM]
            var fiterDara: TicketFilterPanelView.FilterData
        }
    }
    
    enum LoadSections {
        struct Request {
            var title: String
            var fromId: Int
            var toId: Int
            var date: String
            var filterData: TicketFilterPanelView.FilterData?
        }
        struct Response {
            var section : TicketsSectionVM
        }
        struct ViewModel {
            var section : TicketsSectionVM
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

}
