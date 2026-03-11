import UIKit

final class TicketsViewController: UIViewController {
    
    typealias Model = TicketsModel
    
    // MARK: - Constants
    private enum Constants {
        static let fatalError = "Ошибка создания"
        static let backgroundColor = UIColor(hex: "#141414")!
        
        static let buttonHeight: CGFloat = 150
        static let buttonWidth: CGFloat = 170
        static let buttonLeft: CGFloat = -15
        
        static let catRight: CGFloat = 10
        static let catTop: CGFloat = -310
        static let catHeight: CGFloat = 400
        static let catWidth: CGFloat = 200
        static let catWRotate: CGFloat = 180
        
        static let filterName = "Установить фильтр"
        static let filterChooses = ["Все", "Новостной сайт", "Телеграмм"]
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
        
        static let autoButtonName: String = "Авто"
        static let autoButtonWidth: CGFloat = 210
        static let autoButtonHeight: CGFloat = 30
        
        
        static let busButtonName: String = "Автобус"
        static let busButtonWidth: CGFloat = 210
        static let busButtonHeight: CGFloat = 30
        
        static let buttonColor : UIColor = UIColor(hex: "#DB8C42")!
        static let backgroundChosenButtonColor = UIColor(hex: "#E1740E")!
        static let buttonFontSize: CGFloat = 16
        
    }
    
    // MARK: - Fields
    
    private var interactor: TicketsBusinessLogic
    private let service = TicketsService()
    private let loader = BusforHiddenLoader()
    
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
    private let autoButton = BasicButtonView(label: Constants.autoButtonName, width: Constants.autoButtonWidth, height: Constants.autoButtonHeight)
    private let bussButton = BasicButtonView(label: Constants.busButtonName, width: Constants.buttonWidth, height: Constants.busButtonHeight)
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Lifecycle
    init(interactor: TicketsBusinessLogic) {
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
        updateButtonsState(isBusSelected: true)
    }
    
    // MARK: - UI
    private func configureUI() {
        configureBackground()
        configureCatButton()
        configureFilterButton()
        configureBottomButtons()
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
    }
    
    private func configureBottomButtons() {
        view.addSubview(buttonStack)
        buttonStack.addArrangedSubview(bussButton)
        buttonStack.addArrangedSubview(autoButton)
        
        buttonStack.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
        buttonStack.pinHorizontal(to: view, 20)
        
        bussButton.isUserInteractionEnabled = false
        
        let autoTap = UITapGestureRecognizer(target: self, action: #selector(autoButtonTapped))
        autoButton.addGestureRecognizer(autoTap)
        autoButton.isUserInteractionEnabled = true
        
    }
    
    private func configureScroll() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        scrollView.pinTop(to: pawMenu.bottomAnchor, 30)
        scrollView.pinHorizontal(to: view, 10)
        scrollView.pinBottom(to: buttonStack.topAnchor, 20)
        
        contentView.pin(to: scrollView)
        contentView.pinWidth(to: scrollView)
        
        stackView.pinHorizontal(to: contentView)
        stackView.pinTop(to: contentView.topAnchor)
        stackView.pinBottom(to: contentView.bottomAnchor, Constants.contentTop)
    }
    
    
    // MARK: - Data
    
    private func setupData() {
        let image = UIImage(named: "cat_belapol") ?? UIImage()
        
        Task {
            do {
                let result = try await loadBusforTickets()
                
                sections = [
                    TicketsSectionVM(
                        title: "Минск → Варшава | Билеты на автобус",
                        items: result
                    ),
                    TicketsSectionVM(
                        title: "Варшава → Минск | Билеты на автобус",
                        items: [
                            TicketsVM(
                                title: "Telegram source",
                                stationFrom: "Минск",
                                stationTo: "Варшава",
                                point: "Проверено по каналу",
                                date: "Сегодня",
                                time: "18:00 -\n18:20",
                                image: image,
                                grade: "7.0"
                            ),
                            TicketsVM(
                                title: "News / site source",
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
                
                await MainActor.run {
                    self.renderSections()
                }
            }
        }
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
    
    private func updateButtonsState(isBusSelected: Bool) {
        styleButton(bussButton, isSelected: isBusSelected)
        styleButton(autoButton, isSelected: !isBusSelected)
    }
    
    private func styleButton(_ button: UIButton, isSelected: Bool) {
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.clipsToBounds = true
        
        if isSelected {
            button.backgroundColor = Constants.backgroundChosenButtonColor
            button.titleLabel?.font = .boldSystemFont(ofSize: Constants.buttonFontSize + 2)
        } else {
            button.backgroundColor = Constants.buttonColor
            button.titleLabel?.font = .boldSystemFont(ofSize: Constants.fontSize)
        }
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
    
    private func loadBusforTickets() async throws -> [TicketsVM] {
        let fromId = 4102
        let toId = 3465
        let date = "2026-03-18"

        let data = try await loader.load(
            fromId: fromId,
            toId: toId,
            date: date,
            passengers: 1
        )

        guard let searchId = data.searchId else {
            throw NSError(
                domain: "BusforHiddenLoader",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Search ID not found"]
            )
        }

        let tickets = try await service.loadSearchResults(
            searchId: searchId,
            fromId: fromId,
            toId: toId,
            on: date,
            passengers: 1,
            domainId: 10
        )

        return service.fetchTickets(searchData: tickets)
    }
    
    
    @objc
    private func autoButtonTapped() {
        updateButtonsState(isBusSelected: false)
        interactor.loadNotAnimatedView(request: Model.LoadView.Request(vc: CarShareAssembly.build()))
    }
}

