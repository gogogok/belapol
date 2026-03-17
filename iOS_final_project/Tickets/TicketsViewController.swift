import UIKit
import SafariServices

final class TicketsViewController: UIViewController {
    
    typealias Model = TicketsModel
    
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
        
        static let filterRight: CGFloat = 20
        static let filterTop: CGFloat = 30
        
        static let catButtonTop: CGFloat = -15
        
        static let pawMenuSize: CGFloat = 64
        
        static let sectionSpacing: CGFloat = 16
        static let contentTop: CGFloat = 12
        
        static let fontName = "InriaSans-Bold"
        static let titleFontSize: CGFloat = 20
        
        static let autoButtonName = "Авто"
        static let autoButtonWidth: CGFloat = 210
        static let autoButtonHeight: CGFloat = 30
        
        static let busButtonName = "Автобус"
        static let busButtonWidth: CGFloat = 210
        static let busButtonHeight: CGFloat = 30
        
        static let buttonColor: UIColor = UIColor(hex: "#DB8C42") ?? .orange.withAlphaComponent(0.8)
        static let backgroundChosenButtonColor = UIColor(hex: "#E1740E") ?? .orange
        
        static let minskId = 4102
        static let warsawId = 3465
        static let defaultPassengers = 1
        static let defaultDomainId = 10
        static let defaultSectionTitle = "Найденные билеты"
    }
    
    // MARK: - Fields
    private var interactor: TicketsBusinessLogic
    private var loadingView: LoadingView?
    private var hasLoadedSuccessfullyOnce = false
    
    private var sections: [TicketsSectionVM] = []
    private var currentFilter: TicketFilterPanelView.FilterData?
    
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
    private let filter = TicketFilterPanelView()
    private let autoButton = BasicButtonView(
        label: Constants.autoButtonName,
        width: Constants.autoButtonWidth,
        height: Constants.autoButtonHeight
    )
    private let bussButton = BasicButtonView(
        label: Constants.busButtonName,
        width: Constants.busButtonWidth,
        height: Constants.busButtonHeight
    )
    
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
        filter.setWidth(275)
        
        filter.onApply = { [weak self] filterData in
            self?.applyFilter(filterData)
        }
        
        filter.onReset = { [weak self] in
            self?.resetFilter()
        }
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
            self?.interactor.loadView(request: Model.LoadView.Request(vc: TicketsCollectionAssembly.build()))
        }
        
        pawMenu.onOpenStateChange = { [weak self] isOpen in
            guard let self else {return}
            if (isOpen) {
                view.bringSubviewToFront(pawMenu)
            } else {
                view.bringSubviewToFront(filter)
            }
            self.filter.isUserInteractionEnabled = !isOpen
            self.filter.alpha = isOpen ? 0.3 : 1.0
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
        
        if !hasLoadedSuccessfullyOnce {
            showLoading()
        }
        
        clearStack()
        sections = []

        Task {
            let date = defaultRequestDate()

            await interactor.loadSections(request: Model.LoadSections.Request(title: "Минск → Варшава | Билеты на автобус", fromId: Constants.minskId, toId: Constants.warsawId, date: date))
                                   

            await interactor.loadSections(request: Model.LoadSections.Request(title: "Варшава → Минск | Билеты на автобус", fromId: Constants.warsawId, toId: Constants.minskId, date: date))
        }
    }
    
    // MARK: - Render
    private func renderSections() {
        clearStack()
        
        for section in sections {
            let titleLabel = makeSectionTitle(section.title)
            stackView.addArrangedSubview(titleLabel)
            
            if section.items.isEmpty {
                let emptyLabel = makeEmptyLabel(text: "По вашему запросу билеты не найдены")
                stackView.addArrangedSubview(emptyLabel)
                continue
            }
            
            for item in section.items {
                let card = BusTicketsView()
                card.configure(
                    title: item.title,
                    stationFrom: item.fromAddress ?? item.stationFrom,
                    stationTo: item.toAddress ?? item.stationTo,
                    point: item.point,
                    date: item.date,
                    time: item.time,
                    image: item.image
                )
                card.onTitleTap = { [weak self] in
                    self?.openSafari(urlString: item.ticketURL)
                }

                card.onFromTap = { [weak self] in
                    self?.openMaps(address: item.stationFrom + ", " +  (item.fromAddress ?? item.stationFrom))
                }

                card.onToTap = { [weak self] in
                    self?.openMaps(address: item.stationTo + ", " +  (item.toAddress ?? item.stationTo))
                }
                stackView.addArrangedSubview(card)
            }
        }
    }
    
    private func renderEmptyState() {
        clearStack()
        
        let titleLabel = makeSectionTitle(Constants.defaultSectionTitle)
        let emptyLabel = makeEmptyLabel(text: "Не удалось загрузить билеты")
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emptyLabel)
    }
    
    private func clearStack() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
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
    
    private func makeEmptyLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: Constants.fontName, size: 16)
        return label
    }
    
    // MARK: - Filter
    private func applyFilter(_ filterData: TicketFilterPanelView.FilterData) {
        showLoading()
        
        interactor.loadTickets(request: Model.LoadTickets.Request(filterData: filterData))
    }
    
    private func resetFilter() {
        currentFilter = nil
        setupData()
    }
    
    private func makeSectionTitleText(from filterData: TicketFilterPanelView.FilterData?) -> String {
        let from = filterData?.departurePlace?.trimmingCharacters(in: .whitespacesAndNewlines)
        let to = filterData?.arrivalPlace?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let from, !from.isEmpty, let to, !to.isEmpty {
            return "\(from) → \(to) | Билеты на автобус"
        }
        
        if let from, !from.isEmpty {
            return "\(from) → ... | Билеты на автобус"
        }
        
        if let to, !to.isEmpty {
            return "... → \(to) | Билеты на автобус"
        }
        
        return Constants.defaultSectionTitle
    }
    
    // MARK: - Bottom buttons
    private func updateButtonsState(isBusSelected: Bool) {
        styleButton(bussButton, isSelected: isBusSelected)
        styleButton(autoButton, isSelected: !isBusSelected)
    }
    
    private func styleButton(_ button: UIView, isSelected: Bool) {
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.clipsToBounds = true
        button.backgroundColor = isSelected
            ? Constants.backgroundChosenButtonColor
            : Constants.buttonColor
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
    
    func displayTickets(vm: Model.LoadTickets.ViewModel) {
        Task {
            if (!vm.hasError) {
                await MainActor.run {
                    self.currentFilter = vm.fiterDara
                    self.sections = vm.loadedSections
                    self.renderSections()
                    self.loadingView?.hide()
                    self.loadingView = nil
                }
            } else {
                self.loadingView?.hide()
                self.loadingView = nil
                self.showErrorAlert(message: "Error in loading tickets")
            }
        }
    }
    
    func loadSections(vm: Model.LoadSections.ViewModel) {
        
        
        Task {
            await MainActor.run {
                self.sections.append(vm.section)
                self.renderSections()
            }
            
            if !self.hasLoadedSuccessfullyOnce {
                self.hasLoadedSuccessfullyOnce = true
                self.loadingView?.hide()
                self.loadingView = nil
            }
        }
    }
    
    // MARK: - Actions
    @objc
    private func autoButtonTapped() {
        updateButtonsState(isBusSelected: false)
        interactor.loadNotAnimatedView(request: Model.LoadView.Request(vc: CarShareAssembly.build()))
    }
    
    // MARK: - Loading / Alerts
    private func showLoading() {
        if loadingView != nil { return }
        
        let loadView = LoadingView()
        loadingView = loadView
        loadView.show(in: view)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    // MARK: - Internet
    private func openSafari(urlString: String?) {
        guard var urlString else { return }

        if urlString.hasPrefix("/") {
            urlString = "https://busfor.by" + urlString
        }

        guard let url = URL(string: urlString),
              let scheme = url.scheme,
              scheme == "http" || scheme == "https"
        else {
            print("Invalid URL:", urlString)
            return
        }

        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    private func openMaps(address: String?) {
        guard let address, !address.isEmpty else { return }

        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "http://maps.apple.com/?q=\(encoded)"

        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func defaultRequestDate() -> String {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return formatRequestDate(tomorrow) ?? "2026-03-18"
    }
    
    private func formatRequestDate(_ date: Date?) -> String? {
        guard let date else { return nil }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
