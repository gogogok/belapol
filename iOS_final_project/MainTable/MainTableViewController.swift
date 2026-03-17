import UIKit

final class MainTableViewController: UIViewController {
    
    typealias Model = MainTableModel
    
    //MARK: - Constants
    private enum Constants {
        static let backgroundColor: UIColor = UIColor(hex: "#141414") ?? .black
        static let fontSize: CGFloat = 17
        static let fatalError: String = "Ошибка создания"
        
        static let buttonHeight : CGFloat = 150
        static let buttonHWidth : CGFloat = 170
        static let buttonLeft : CGFloat = -15
        
        static let pawButtonTop: CGFloat = 10
        
        static let brTrLabelName: String = "Брест - Тересполь"
        static let brTrLabelWidth: CGFloat = 210
        static let brTrLabelHeight: CGFloat = 30
        static let brLabelLeft: CGFloat = 10
        static let brTop: CGFloat = -10
        
        static let secondLabelName: String = "Берестовица - Бобровники"
        static let secondTop: CGFloat = 20
        
        static let brTrButtonName: String = "Архив очередей"
        static let brTrButtonWidth: CGFloat = 160
        static let brButtonLeft: CGFloat = 10
        
        static let filterName: String = "Выбрать пункт"
        static let filterChooses: [String] = ["Все", "Брест - Тересполь","Берестовица - Бобровники"]
        
        static let catLeft: CGFloat = -60
        static let catBottom: CGFloat = -250
        static let catHeight: CGFloat = 400
        static let catWidth: CGFloat = 200
        static let catWRotate: CGFloat = 20
        
        static let filterFontSize: CGFloat = 12
        static let fontName: String = "InriaSans-Bold"
    }
    
    //MARK: - Fields
    
    var interactor : MainTableBusinessLogic
    private let queueService: BorderQueueService = BorderQueueService()
    private var archiveLoadingView: LoadingView?
    
    let catButton = CatBackButton()
    let pawMenu = PawMenuView()
    
    private let tablesStack = UIStackView()
    private let brTrSection = UIView()
    private let secondSection = UIView()
    
    let brTrLabel = BasicLabelView(label: Constants.brTrLabelName, width: Constants.brTrLabelWidth, height: Constants.brTrLabelHeight)
    let brTrButton = BasicButtonView(label: Constants.brTrButtonName, width: Constants.brTrButtonWidth, height: Constants.brTrLabelHeight)
    let gridBrTr = BorderTableView()
    
    let secondLabel = BasicLabelView(label: Constants.secondLabelName, width: Constants.brTrLabelWidth, height: Constants.brTrLabelHeight)
    let secondButton = BasicButtonView(label: Constants.brTrButtonName, width: Constants.brTrButtonWidth, height: Constants.brTrLabelHeight)
    let secondGrid = BorderTableView()
    
    let filter = ChooseFilterButton(title: Constants.filterName, fontSize: Constants.filterFontSize, chooses: Constants.filterChooses)
    
    private var selectedCheckpointName: String?
    
    let cat: UIImageView = {
        let label = UIImageView()
        label.image = UIImage(named: "cat_belapol")
        label.contentMode = .scaleAspectFit
        label.tintColor = .white
        return label
    }()

    private var calendarSheet: CalendarBottomSheetView?
    private var calendarTableView: CalendarTable?

    
    //MARK: - Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadQueueData()
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    //MARK: - Lyfecycle
    init(interactor: MainTableBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    //MARK: - Configure UI
    private func configureUI() {
        configureBackground()
        configureCatButton()
        configureFilterButton()
        configureTableView()
        view.bringSubviewToFront(pawMenu)
        view.bringSubviewToFront(filter)
    }

    private func configureBackground() {
        view.backgroundColor = Constants.backgroundColor
        
        view.addSubview(cat)
        
        cat.transform = CGAffineTransform(rotationAngle: Constants.catWRotate * .pi / 180)
        cat.clipsToBounds = true
        
        cat.setWidth(Constants.catWidth)
        cat.setHeight(Constants.catHeight)
        
        cat.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Constants.catBottom)
        cat.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, Constants.catLeft)
    }
    
    
    private func configureCatButton() {
        view.addSubview(catButton)
        catButton.setHeight(Constants.buttonHeight)
        catButton.setWidth(Constants.buttonHWidth)
        catButton.pinTop(to: view.safeAreaLayoutGuide.topAnchor, -10)
        catButton.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, Constants.buttonLeft)
        catButton.isUserInteractionEnabled = false
        
        view.addSubview(pawMenu)
        pawMenu.setWidth(64)
        pawMenu.setHeight(64)
        pawMenu.pinCenterX(to: catButton, -5)
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
    
    private func configureFilterButton() {
        view.addSubview(filter)
        filter.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, 20)
        filter.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 30)
        
        filter.onTapAll = { [weak self] in
            self?.showAllTables()
        }
        
        filter.onTapFirst = { [weak self] in
            self?.showOnlyBrest()
        }
        
        filter.onTapSecond = { [weak self] in
            self?.showOnlyBerestovitsa()
        }
    }
    
    private func configureTableView() {
        view.addSubview(tablesStack)
        tablesStack.axis = .vertical
        tablesStack.spacing = 20
        tablesStack.alignment = .fill
        tablesStack.distribution = .fill
        
        tablesStack.pinTop(to: catButton.bottomAnchor, Constants.brTop)
        tablesStack.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor)
        tablesStack.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor)
        
        tablesStack.addArrangedSubview(brTrSection)
        
        brTrSection.addSubview(brTrLabel)
        (brTrLabel as UIView).pinTop(to: brTrSection.topAnchor, 0)
        (brTrLabel as UIView).pinLeft(to: brTrSection.leadingAnchor, Constants.brLabelLeft)
        
        brTrSection.addSubview(brTrButton)
        brTrButton.pinTop(to: brTrSection.topAnchor)
        brTrButton.pinLeft(to: brTrLabel.trailingAnchor, Constants.brButtonLeft)
        brTrButton.addTarget(self, action: #selector(calendarButtonTapped(_:)), for: .touchUpInside)
        
        brTrSection.addSubview(gridBrTr)
        gridBrTr.pinTop(to: brTrLabel.bottomAnchor, 20)
        gridBrTr.pinHorizontal(to: brTrSection, 20)
        gridBrTr.pinBottom(to: brTrSection.bottomAnchor, 0)
        
        applyInitialState(to: gridBrTr)
        
        tablesStack.addArrangedSubview(secondSection)
        
        secondSection.addSubview(secondLabel)
        (secondLabel as UIView).pinTop(to: secondSection.topAnchor, 0)
        (secondLabel as UIView).pinLeft(to: secondSection.leadingAnchor, Constants.brLabelLeft)
        secondLabel.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        secondLabel.font = UIFont(name: Constants.fontName, size: 13)
        
        secondSection.addSubview(secondButton)
        secondButton.pinTop(to: secondSection.topAnchor, 0)
        secondButton.pinLeft(to: secondLabel.trailingAnchor, Constants.brButtonLeft)
        secondButton.addTarget(self, action: #selector(calendarButtonTapped(_:)), for: .touchUpInside)
        
        secondSection.addSubview(secondGrid)
        secondGrid.pinTop(to: secondLabel.bottomAnchor, 20)
        secondGrid.pinHorizontal(to: secondSection, 20)
        secondGrid.pinBottom(to: secondSection.bottomAnchor, 0)
        
        applyInitialState(to: secondGrid)
    }
    
    private func loadQueueData() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let brestQueue = try await queueService.fetchQueue(point: "brest")
                let berestovitsaQueue = try await queueService.fetchQueue(point: "berestovitsa")
                
                await MainActor.run {
                    self.apply(queue: brestQueue, to: self.gridBrTr)
                    self.apply(queue: berestovitsaQueue, to: self.secondGrid)
                }
            } catch {
                print("Ошибка загрузки очереди Брест: \(error)")
            }
        }
    }

    private func apply(queue: Model.BorderQueueInfo, to tableView: BorderTableView) {
        tableView.configure(
            headerLeft: queue.updatedAt,
            headerRight: queue.directionText,
            rows: [
                .init(iconSystemName: "car.fill", valueText: queue.cars),
                .init(iconSystemName: "bus.fill", valueText: queue.buses),
                .init(iconSystemName: "truck.box.fill", valueText: queue.trucks)
            ]
        )
    }
    
    private func applyInitialState(to tableView: BorderTableView) {
        tableView.configure(
            headerLeft: "--.--.---- --:--",
            headerRight: "выезд из РБ",
            rows: [
                .init(iconSystemName: "car.fill", valueText: "..."),
                .init(iconSystemName: "bus.fill", valueText: "..."),
                .init(iconSystemName: "truck.box.fill", valueText: "...")
            ]
        )
    }
    
    //MARK: - Objc
    @objc
    private func calendarButtonTapped(_ sender: UIButton) {
        if sender === brTrButton {
            selectedCheckpointName = "Брест"
        } else if sender === secondButton {
            selectedCheckpointName = "Берестовица"
        }
        
        interactor.loadCalendarView(request: Model.LoadMainTable.Request())
    }
    
    
    //MARK: - Present func
    func displayView(vc: UIViewController) {
        guard let nav = navigationController else { return }
        
        var stack = nav.viewControllers
        stack[stack.count - 1] = vc
        nav.setViewControllers(stack, animated: true)
    }
    
    public func presentCalendarSheet() {
        print("Первая кнопка нажата")
        let sheet = CalendarBottomSheetView()
        
        sheet.onPick = { [weak self] date in
            guard let self else { return }
            
            let df = DateFormatter()
            df.dateFormat = "dd.MM.yyyy"
            let dateString = df.string(from: date)
            
            guard let checkpointName = self.selectedCheckpointName else { return }
            
            self.loadArchiveData(
                checkpointName: checkpointName,
                dateString: dateString
            )
        }
        
        sheet.onClose = { [weak self] in
            self?.calendarSheet = nil
        }

        calendarSheet = sheet
        sheet.show(in: view)
    }
    
    public func presentCalendarTable(data: Model.ArchiveQueueTableData) {
        
        if archiveLoadingView == nil {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Не удалось загрузить архив, попробуйте позже :(",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            
            present(alert, animated: true)
        }
        
        archiveLoadingView?.hide()
        
        let table = CalendarTable(data: data)
        
        table.onClose = { [weak self] in
            self?.calendarTableView = nil
        }

        table.onShareTap = { [weak self] vc in
            self?.present(vc, animated: true)
        }
        
        calendarTableView = table
        table.show(in: view)
    }
    
    
    private func loadArchiveData(checkpointName: String, dateString: String) {
        showArchiveLoading()
        interactor.loadArchiveData(request: Model.LoadArchiveData.Request(view: self.view, request: Model.ArchiveQueueScreenshotRequest(checkpointName: checkpointName, date: dateString)))
    }
    
    private func showArchiveLoading() {
        if archiveLoadingView != nil { return }
        
        let loadingView = LoadingView()
        archiveLoadingView = loadingView
        loadingView.show(in: view)
    }

    private func hideArchiveLoading() {
        archiveLoadingView?.hide()
        archiveLoadingView = nil
    }
    
    // MARK: - Filter methods
    private func showAllTables() {
        brTrSection.isHidden = false
        secondSection.isHidden = false
        filter.titleLabel.text = "Все"
    }
    
    private func showOnlyBrest() {
        brTrSection.isHidden = false
        secondSection.isHidden = true
        filter.titleLabel.text = "Брест - Тересполь"
    }
    
    private func showOnlyBerestovitsa() {
        brTrSection.isHidden = true
        secondSection.isHidden = false

        filter.titleLabel.text = "Берестовица - Бобровники"
    }
}

