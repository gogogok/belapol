import UIKit

final class TicketsCollectionViewController: UIViewController {
    
    typealias Model =  TicketsCollectionModel
    
    // MARK: - Constants
    private enum Constants {
        static let fatalError = "Ошибка создания"
        static let backgroundColor = UIColor(hex: "#141414")!
        
        static let buttonHeight: CGFloat = 150
        static let buttonWidth: CGFloat = 170
        static let buttonLeft: CGFloat = -15
        
        static let catRight: CGFloat = -90
        static let catTop: CGFloat = -300
        static let catHeight: CGFloat = 400
        static let catWidth: CGFloat = 200
        static let catWRotate: CGFloat = 225
        
        static let filterName = "Установить фильтр"
        static let filterChooses = ["Все", "Предстоящие поездки", "Прошедшие поездки"]
        static let fontSize: CGFloat = 14
        static let fontName = "InriaSans-Bold"
        
        static let filterRight: CGFloat = 20
        static let filterTop: CGFloat = 30
        
        static let catButtonTop: CGFloat = -15
        
        static let pawMenuSize: CGFloat = 64
        
        static let horizontalInset: CGFloat = 20
        static let sectionSpacing: CGFloat = 16
        static let itemSpacing: CGFloat = 12
        static let contentTop: CGFloat = 12
        
        static let titleTopInset: CGFloat = 8
        static let titleFontSize: CGFloat = 20
    
        
        static let buttonColor : UIColor = UIColor(hex: "#DB8C42")!
        static let backgroundChosenButtonColor = UIColor(hex: "#E1740E")!
        static let buttonFontSize: CGFloat = 16
        
    }
    
    // MARK: - Fields
    
    private var interactor:  TicketsCollectionBusinessLogic
    
    private var sections: [TicketsSectionVM] = []
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private let contentView = UIView()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.sectionSpacing
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private let cat: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cat_belapol")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let catButton = CatBackButton()
    private let pawMenu = PawMenuView()
    private let filter = ChooseFilterButton(title: Constants.filterName, chooses: Constants.filterChooses)
    private let addButton : BasicButtonView = BasicButtonView(label: "+ Добавить билет", width: 150, height: 40)
    
    // MARK: - Lifecycle
    init(interactor:  TicketsCollectionBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupData()
    }
    
    // MARK: - UI
    private func configureUI() {
        configureBackground()
        configureCatButton()
        configureFilterButton()
        configurAddButton()
        configureScroll()
        view.bringSubviewToFront(pawMenu)
        view.bringSubviewToFront(filter)
    }
    
    private func configureBackground() {
        view.backgroundColor = Constants.backgroundColor
        
        view.addSubview(cat)
        cat.clipsToBounds = true
        cat.setWidth(Constants.catWidth)
        cat.setHeight(Constants.catHeight)
        cat.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.catTop)
        cat.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, Constants.catRight)
        cat.transform = CGAffineTransform(rotationAngle: Constants.catWRotate * .pi / 180)
    }
    
    private func configureFilterButton() {
        view.addSubview(filter)
        filter.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, Constants.filterRight)
        filter.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.filterTop)
        filter.titleLabel.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
    }
    
    private func configureCatButton() {
        view.addSubview(catButton)
        catButton.setHeight(Constants.buttonHeight)
        catButton.setWidth(Constants.buttonWidth)
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
        
        pawMenu.onOpenStateChange = { [weak self] isOpen in
            guard let self else { return }
            self.filter.isUserInteractionEnabled = !isOpen
            self.filter.alpha = isOpen ? 0.3 : 1.0
        }
    }
    
   
    
    private func configureScroll() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        scrollView.pinTop(to: pawMenu.bottomAnchor, 30)
        scrollView.pinHorizontal(to: view, 10)
        scrollView.pinBottom(to: addButton.topAnchor, 20)
        
        contentView.pin(to: scrollView)
        contentView.pinWidth(to: scrollView)
        
        stackView.pinHorizontal(to: contentView)
        stackView.pinTop(to: contentView.topAnchor)
        stackView.pinBottom(to: contentView.bottomAnchor, Constants.contentTop)
    }
    
    private func configurAddButton() {
        view.addSubview(addButton)
        addButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 20)
        addButton.pinCenterX(to: view)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    
    // MARK: - Data
    
    private func setupData() {
        let image = UIImage(named: "cat_belapol") ?? UIImage()
        
        sections = [
            TicketsSectionVM(
                title: "Предстоящие поездки",
                items: [
                    TicketsVM(
                        title: "Ecolines",
                        stationFrom: "Минск",
                        stationTo: "Варшава",
                        point: "Проверено по каналу",
                        date: "Сегодня",
                        time: "18:00 -\n18:20",
                        image: image,
                        grade: "7.0"
                    ),
                    TicketsVM(
                        title: "Ecolines",
                        stationFrom: "Минск",
                        stationTo: "Варшава",
                        point: "Актуально по сайту",
                        date: "Завтра",
                        time: "09:40 -\n10:00",
                        image: image,
                        grade: "9.1"
                    )
                ]
            )
        ]
        
        self.renderSections()
    }
    
    // MARK: - Render
    private func renderSections() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for section in sections {
            let titleLabel = makeSectionTitle(section.title)
            stackView.addArrangedSubview(titleLabel)
            
            for item in section.items {
                let card = BusTicketsView()
                card.configure(
                    title: item.title,
                    stationFrom: item.stationFrom,
                    stationTo: item.stationTo,
                    point: item.point,
                    date: item.date,
                    time: item.time,
                    image: item.image,
                    grade: item.grade
                )
                stackView.addArrangedSubview(card)
            }
        }
    }
    
    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: Constants.fontName, size: Constants.titleFontSize)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = text
        return label
    }
    
    
    // MARK: - Present
    func displayView(vc: UIViewController) {
        guard let nav = navigationController else { return }
        var stack = nav.viewControllers
        stack[stack.count - 1] = vc
        nav.setViewControllers(stack, animated: true)
    }
    
    func displayNotAnimatedView(vc: UIViewController) {
        guard let nav = navigationController else { return }
        var stack = nav.viewControllers
        stack[stack.count - 1] = vc
        nav.setViewControllers(stack, animated: false)
    }
    
    @objc
    private func addButtonTapped() {
        present(AddTicketAssembly.build(), animated: true)
    }
    
}

