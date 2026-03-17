final class CarShareInteractor : CarShareBusinessLogic{
    
    typealias Model = CarShareModel
   
    private var presenter: CarSharePresentationLogic
    private let loader = CarPostsRemoteLoader(
        urlString: "http://127.0.0.1:8000/car_posts.json"
    )
    
    init (presenter: CarSharePresentationLogic) {
        self.presenter = presenter
    }
    
    func loadView(request: Model.LoadView.Request) {
        presenter.presentView(response: Model.LoadView.Response(vc: request.vc))
    }
    
    func loadNotAnimatedView(request: Model.LoadView.Request) {
        presenter.presentNotAnimatedView(response: Model.LoadView.Response(vc: request.vc))
    }
    
    func loadRefreshPosts(request: Model.LoadPosts.Request) {
        guard let viewController = request.vc as? CarShareViewController else { return }

        loader.reload { [weak self, weak viewController] result in
            guard let self = self, let viewController = viewController else { return }

            viewController.isLoading = false

            let sectionVMs: [AutoSectionVM]

            switch result {
            case .success(let posts):
                sectionVMs = self.makeSections(from: posts)
            case .failure(let error):
                print("Ошибка загрузки актуальных постов: \(error)")
                sectionVMs = []
            }

            self.presenter.presentRefreshPosts(
                response: CarShareModel.LoadPosts.Response(
                    vc: viewController,
                    sections: sectionVMs
                )
            )
        }
    }
    
    private func makeSections(from posts: [Model.CarPostDTO]) -> [AutoSectionVM] {
           let grouped = Dictionary(grouping: posts, by: { $0.direction })
           
           let orderedTitles = [
               "Минск → Варшава",
               "Варшава → Минск",
               "Не определено"
           ]
           
           return orderedTitles.compactMap { title in
               guard let posts = grouped[title], !posts.isEmpty else { return nil }
               
               return AutoSectionVM(
                   title: title,
                   items: posts.map {
                       CarVM(
                           date: $0.date,
                           time: $0.time,
                           description: $0.description,
                           userName: $0.userName,
                           nickname: $0.nickname
                       )
                   }
               )
           }
       }
    
    
}
