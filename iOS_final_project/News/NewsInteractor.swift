import UIKit

final class NewsInteractor: NewsBusinessLogic {
    
    typealias Model = NewsModel
    
    private var presenter: NewsPresentationLogic
    private let service = SputnikNewsService()
    
    private let borderLoader = BorderPostsRemoteLoader(
        urlString: "http://127.0.0.1:8000/border_posts.json"
    )
    
    init(presenter: NewsPresentationLogic) {
        self.presenter = presenter
    }
    
    func loadView(request: Model.LoadView.Request) {
        presenter.presentView(response: Model.LoadView.Response(vc: request.vc))
    }
    
    func loadNews(request: Model.LoadPosts.Request) {
        Task { [weak self] in
            guard let self else { return }
            
            let webNews = await loadWebNews()
            let telegramNews = await loadTelegramNews()
            let allNews = webNews + telegramNews
            
            await MainActor.run {
                self.presenter.presentNews(
                    response: Model.LoadPosts.Response(
                        vc: request.vc,
                        news: allNews
                    )
                )
            }
        }
    }
    
    private func loadWebNews() async -> [Model.NewsVM] {
        do {
            return try await service.fetchLatestNews()
        } catch {
            print("Ошибка загрузки новостей сайта: \(error)")
            return []
        }
    }
    
    private func loadTelegramNews() async -> [Model.NewsVM] {
        let posts = await loadBorderPosts()
        
        return posts.map { post in
            let image = makeImage(from: post.image)
            
            return Model.NewsVM(
                title: post.title,
                dateText: post.date,
                subtitle: post.description,
                image: image,
                url: URL(string: "https://t.me/belgranica"),
                isTelegramPost: true
            )
        }
    }
    
    private func loadBorderPosts() async -> [Model.BorderPost] {
        await withCheckedContinuation { continuation in
            borderLoader.reload { [weak self] result in
                guard let self else {
                    continuation.resume(returning: [])
                    return
                }
                
                switch result {
                case .success(let posts):
                    print("Загружены border posts с сервера: \(posts.count)")
                    continuation.resume(returning: posts)
                    
                case .failure(let error):
                    print("Ошибка загрузки border posts с сервера: \(error)")
                    let localPosts = self.loadLocalPosts()
                    print("Загружены border posts из bundle: \(localPosts.count)")
                    continuation.resume(returning: localPosts)
                }
            }
        }
    }
    
    private func loadLocalPosts() -> [Model.BorderPost] {
        guard
            let url = Bundle.main.url(forResource: "border_posts", withExtension: "json")
        else {
            print("Не найден локальный border_posts.json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(Model.BorderResponse.self, from: data)
            return response.posts
        } catch {
            print("Ошибка чтения локального border_posts.json: \(error)")
            return []
        }
    }
    
    
    private func makeImage(from imageValue: String) -> UIImage? {
        guard !imageValue.isEmpty else {
            return UIImage(named: "border")
        }
        
        let fileName = URL(fileURLWithPath: imageValue).lastPathComponent
        let baseName = (fileName as NSString).deletingPathExtension
        
        if let image = UIImage(named: baseName) {
            return image
        }
        
        if let image = UIImage(named: fileName) {
            return image
        }
        
        return UIImage(named: "border")
    }
}
