import UIKit
import SafariServices

final class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    typealias Model = NewsModel
    
    private enum NewsFilter {
        case all
        case web
        case telegram
    }
    
    //MARK: - Constants
    private enum Constants {
        static let fatalError: String = "Ошибка создания"
        
        static let backgroundColor: UIColor = UIColor(hex: "#141414") ?? .black
        
        static let buttonHeight : CGFloat = 150
        static let buttonHWidth : CGFloat = 170
        static let buttonLeft : CGFloat = -15
        
        static let catRight: CGFloat = -45
        static let catTop: CGFloat = -235
        static let catHeight: CGFloat = 400
        static let catWidth: CGFloat = 200
        
        static let filterName: String = "Установить фильтр"
        static let filterChooses: [String] = ["Все", "Новостной сайт","Телеграмм"]
        static let fontSize: CGFloat = 14
        static let fontName: String = "InriaSans-Bold"
        
        static let filterRight: CGFloat = 20
        static let filterTop: CGFloat = 30
        
        static let catButtonTop: CGFloat = -10
        
        static let pawMenuSize: CGFloat = 64
        static let pawCenterX: CGFloat = -5
        
        static let collectionViewHorizontal: CGFloat = 20
        
        static let itemEstimatedHeight: CGFloat = 200
        static let interGroupSpacing: CGFloat = 16
        static let contentTop: CGFloat = 16
        static let contentLeft: CGFloat = 20
    }
    
    //MARK: - Fields
    
    var interactor : NewsBusinessLogic
    private var loadingView: LoadingView?
    
    private var allItems: [Model.NewsVM] = []
    private var items: [Model.NewsVM] = []
    private var currentFilter: NewsFilter = .all

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceVertical = true
        cv.register(NewsCardCell.self, forCellWithReuseIdentifier: NewsCardCell.reuseId)
        return cv
    }()
    
    private let cat: UIImageView = {
        let label = UIImageView()
        label.image = UIImage(named: "cat_belapol")
        label.contentMode = .scaleAspectFit
        label.tintColor = .white
        return label
    }()
    
    private let catButton = CatBackButton()
    private let pawMenu = PawMenuView()
    private let filter = ChooseFilterButton(title: Constants.filterName, fontSize: Constants.fontSize, chooses: Constants.filterChooses)
    private let card = NewsCardView()
    
    
    //MARK: - Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    //MARK: - Lyfecycle
    init(interactor: NewsBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    //MARK: - Configure UI
    private func configureUI() {
        configureCatButton()
        configureBackground()
        configureFilterButton()
        configureScrollNews()
        view.bringSubviewToFront(pawMenu)
        view.bringSubviewToFront(filter)
    }
    
    private func configureBackground() {
        view.backgroundColor = Constants.backgroundColor
        
        view.addSubview(cat)
        cat.clipsToBounds = true
        cat.setWidth(Constants.catWidth)
        cat.setHeight(Constants.catHeight)
        cat.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Constants.catTop)
        cat.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, Constants.catRight)
    }
    
    private func configureFilterButton() {
        view.addSubview(filter)
        filter.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, Constants.filterRight)
        filter.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.filterTop)
        
        filter.onTapAll = { [weak self] in
                self?.currentFilter = .all
                self?.applyFilter()
            }
            
            filter.onTapFirst = { [weak self] in
                self?.currentFilter = .web
                self?.applyFilter()
            }
            
            filter.onTapSecond = { [weak self] in
                self?.currentFilter = .telegram
                self?.applyFilter()
            }
    }
    
    private func configureCatButton() {
        view.addSubview(catButton)
        catButton.setHeight(Constants.buttonHeight)
        catButton.setWidth(Constants.buttonHWidth)
        catButton.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.catButtonTop)
        catButton.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, Constants.buttonLeft)
        catButton.isUserInteractionEnabled = false
        
        view.addSubview(pawMenu)
        pawMenu.setWidth(Constants.pawMenuSize)
        pawMenu.setHeight(Constants.pawMenuSize)
        pawMenu.pinCenterX(to: catButton)
        pawMenu.pinCenterY(to: catButton)
        
        pawMenu.onTapQueue = { [weak self] in
            self?.interactor.loadView(request: Model.LoadView.Request(vc: MainTableAssembly.build()))
        }
        
        pawMenu.onTapContacts = { [weak self] in
            self?.interactor.loadView(request: Model.LoadView.Request(vc: ContactsAssembly.build()))
        }
        
        pawMenu.onTapNews = { [weak self] in
            self?.interactor.loadView(request: Model.LoadView.Request(vc: NewsAssembly.build()))
        }
        
        pawMenu.onTapTicket = { [weak self] in
            self?.interactor.loadView(request: Model.LoadView.Request(vc: TicketsAssembly.build()))
        }
        
        pawMenu.onTapCollection = { [weak self] in
            self?.interactor.loadView(request:  Model.LoadView.Request(vc: TicketsCollectionAssembly.build()))
        }
    }
    
    private func configureScrollNews() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.pinHorizontal(to: view, Constants.collectionViewHorizontal)
        collectionView.pinTop(to: pawMenu.bottomAnchor)
        collectionView.pinBottom(to: view.bottomAnchor)
        
        showLoading()
        interactor.loadNews(request: Model.LoadPosts.Request(vc: self))
    }

    
    //MARK: - Present func
    func displayView(vc: UIViewController) {
        guard let nav = navigationController else { return }
        var stack = nav.viewControllers
        stack[stack.count - 1] = vc
        nav.setViewControllers(stack, animated: true)
    }
    
    public func presentLoadedNews(vm: Model.LoadPosts.ViewModel) {
        Task {
            let loadedItems = vm.news
            
            await MainActor.run {
                self.allItems = loadedItems
                self.items = loadedItems
                self.loadingView?.hide()
                self.collectionView.reloadData()
            }
        }
    }
    
    
    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(Constants.itemEstimatedHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(Constants.itemEstimatedHeight)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Constants.interGroupSpacing
            section.contentInsets = .init(top: Constants.contentTop, leading: Constants.contentLeft, bottom: Constants.contentTop, trailing: Constants.contentLeft)
            return section
        }
    }


     // MARK: - DataSource
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         items.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let vm = items[indexPath.item]
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCardCell.reuseId, for: indexPath) as! NewsCardCell
         cell.configure(title: vm.title, date: vm.dateText, subtitle: vm.subtitle, image: vm.image)
         return cell
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let news = items[indexPath.item]
        
        if news.isTelegramPost {
            let popup = NewsPostPopupView()
            popup.configure(title: news.title, image: news.image, text: news.subtitle)
            popup.show(in: self.view)
            return
        }
        
        guard let url = news.url else { return }
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
    
    private func showLoading() {
        if loadingView != nil { return }
        
        let loadView = LoadingView()
        loadingView = loadView
        loadView.show(in: view)
    }
    
    // MARK: - Filter method
    private func applyFilter() {
        switch currentFilter {
        case .all:
            items = allItems
            filter.titleLabel.text = "Все"
            
        case .web:
            items = allItems.filter { !$0.isTelegramPost }
            filter.titleLabel.text = "Новостной сайт"
            
        case .telegram:
            items = allItems.filter { $0.isTelegramPost }
            filter.titleLabel.text = "Телеграмм"
        }
        
        collectionView.reloadData()
    }

    
}

