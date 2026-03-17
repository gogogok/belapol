import UIKit

final class CarShareViewController: UIViewController {

    typealias Model = CarShareModel

    // MARK: - Constants
    private enum Constants {
        static let fatalError = "Ошибка создания"
        static let backgroundColor = UIColor(hex: "#141414") ?? .black

        static let buttonHeight: CGFloat = 150
        static let buttonWidth: CGFloat = 170
        static let buttonLeft: CGFloat = -15

        static let catRight: CGFloat = 10
        static let catTop: CGFloat = -310
        static let catHeight: CGFloat = 400
        static let catWidth: CGFloat = 200
        static let catWRotate: CGFloat = 180

        static let filterName = "Установить фильтр"
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
        
        static let buttonColor : UIColor = UIColor(hex: "#DB8C42") ?? .orange.withAlphaComponent(0.8)
        static let backgroundChosenButtonColor = UIColor(hex: "#E1740E") ?? .orange
        static let buttonFontSize: CGFloat = 16

    }

    // MARK: - Fields

    var interactor: CarShareBusinessLogic

    private var sections: [AutoSectionVM] = []
    public var isLoading = false

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
    init(interactor: CarShareBusinessLogic) {
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
        observeAppDidBecomeActive()
        refreshPosts()
    }
            
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPosts()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI
    private func configureUI() {
        configureBackground()
        configureCatButton()
        configureBottomButtons()
        configureScroll()
        view.bringSubviewToFront(pawMenu)
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

        autoButton.isUserInteractionEnabled = false
        
        let busTap = UITapGestureRecognizer(target: self, action: #selector(busButtonTapped))
        bussButton.addGestureRecognizer(busTap)
        bussButton.isUserInteractionEnabled = true
        
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
    
    // MARK: - App lifecycle observing
    private func observeAppDidBecomeActive() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc
    private func handleAppDidBecomeActive() {
        refreshPosts()
    }

    // MARK: - Data
       
       private func refreshPosts() {
           guard !isLoading else { return }
           isLoading = true
           
           interactor.loadRefreshPosts(request: Model.LoadPosts.Request(vc: self))
       }
    // MARK: - Render
    public func renderSections(vm: Model.LoadPosts.ViewModel) {
        sections = vm.sections
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for section in sections {
            let titleLabel = makeSectionTitle(section.title)
            stackView.addArrangedSubview(titleLabel)

            for item in section.items {
                let card = CarShareView()
                card.configure(
                    date: item.date,
                    time: item.time,
                    description: item.description,
                    userName: item.userName,
                    nickname: item.nickname
                )
                
                card.onTapShowMore = { [weak self] in
                    guard let self = self else { return }
                    
                    let popup = RidePostPopupView()
                    popup.configure(
                        name: item.nickname,
                        username: item.userName,
                        text: item.description)
                    popup.show(in: self.view)
                }
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
        styleButton(bussButton, isSelected: !isBusSelected)
        styleButton(autoButton, isSelected: isBusSelected)
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
    

    @objc
    private func busButtonTapped() {
        updateButtonsState(isBusSelected: false)
        interactor.loadNotAnimatedView(request: Model.LoadView.Request(vc: TicketsAssembly.build()))
    }
}

