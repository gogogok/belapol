import UIKit

final class NewsInteractor : NewsBusinessLogic{

    private var presenter: NewsPresentationLogic
    private let service = SputnikNewsService()
    
    init (presenter: NewsPresentationLogic) {
        self.presenter = presenter
    }
    
    func loadView(request: Model.LoadView.Request) {
        presenter.presentView(response: Model.LoadView.Response(vc: request.vc))
    }
    
    func loadNews(request: Model.LoadPosts.Request) {
        Task {
            let news =  await loadAllNews()
            presenter.presentNews(response: Model.LoadPosts.Response(vc: request.vc, news: news))
        }
    }
    
    private func loadAllNews() async -> [Model.NewsVM] {
        var loadedItems: [Model.NewsVM] = []
        
        do {
            let webNews = try await service.fetchLatestNews()
            loadedItems.append(contentsOf: webNews)
        } catch {
            print("Ошибка загрузки новости: \(error)")
        }
        
        loadedItems.append(contentsOf: makeTelegramNews())
        
        return loadedItems
    }
    
    private func makeTelegramNews() -> [Model.NewsVM] {
        let posts = loadPosts()
        
        return posts.map { post in
            let imageName = post.image.isEmpty ? "border" : post.image
            
            return Model.NewsVM(
                title: post.title,
                dateText: post.date,
                subtitle: post.description,
                image: UIImage(named: imageName),
                url: URL(string: "https://t.me/belgranica/174597"),
                isTelegramPost: true
            )
        }
    }
    
    private func loadPosts() -> [Model.BorderPost] {
        guard
            let url = Bundle.main.url(forResource: "border_posts", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let response = try? JSONDecoder().decode(Model.BorderResponse.self, from: data)
        else {
            return []
        }

        return response.posts
    }
    
}
