import UIKit

final class MainTableViewController: UIViewController {
    
    typealias Model = MainTableModel
    
    //MARK: - Constants
    private enum Constants {
        static let backgroundColor: UIColor = UIColor(hex: "#141414")!
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
        
        static let catLeft: CGFloat = -60
        static let catBottom: CGFloat = -250
        static let catHeight: CGFloat = 400
        static let catWidth: CGFloat = 200
        static let catWRotate: CGFloat = 20
    }
    
    //MARK: - Fields
    
    var interactor : MainTableBusinessLogic
    
    let catButton = CatBackButton()
    let pawMenu = PawMenuView()
    
    let brTrLabel = BasicLabelView(label: Constants.brTrLabelName, width: Constants.brTrLabelWidth, height: Constants.brTrLabelHeight)
    let brTrButton = BasicButtonView(label: Constants.brTrButtonName, width: Constants.brTrButtonWidth, height: Constants.brTrLabelHeight)
    let gridBrTr = BorderTableView()
    
    let secondLabel = BasicLabelView(label: Constants.brTrLabelName, width: Constants.brTrLabelWidth, height: Constants.brTrLabelHeight)
    let secondButton = BasicButtonView(label: Constants.brTrButtonName, width: Constants.brTrButtonWidth, height: Constants.brTrLabelHeight)
    let secondGrid = BorderTableView()
    
    let filter = ChooseFilterButton(title: Constants.filterName)
    
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
    }
    
    private func configureFilterButton() {
        view.addSubview(filter)
        filter.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, 20)
        filter.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 30)
    }
    
    private func configureTableView() {
        view.addSubview(brTrLabel)
        (brTrLabel as UIView).pinTop(to: catButton.bottomAnchor, Constants.brTop)
        (brTrLabel as UIView).pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, Constants.brLabelLeft)
        
        view.addSubview(brTrButton)
        brTrButton.pinTop(to: catButton.bottomAnchor, Constants.brTop)
        brTrButton.pinLeft(to: brTrLabel.trailingAnchor, Constants.brButtonLeft)
        brTrButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        
        view.addSubview(gridBrTr)
        gridBrTr.pinTop(to: brTrLabel.bottomAnchor, 20)
        gridBrTr.pinHorizontal(to: view, 20)

        gridBrTr.configure(
            headerLeft: "26.10.2025  00:00",
            headerRight: "Выезд из РБ",
            rows: [
                .init(iconSystemName: "car.fill", valueText: "0"),
                .init(iconSystemName: "bus.fill", valueText: "0"),
                .init(iconSystemName: "truck.box.fill", valueText: "0")
            ]
        )
        
        //2 таблица
        view.addSubview(secondLabel)
        (secondLabel as UIView).pinTop(to: gridBrTr.bottomAnchor, Constants.secondTop)
        (secondLabel as UIView).pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, Constants.brLabelLeft)
        
        view.addSubview(secondButton)
        secondButton.pinTop(to: gridBrTr.bottomAnchor, Constants.secondTop)
        secondButton.pinLeft(to: secondLabel.trailingAnchor, Constants.brButtonLeft)
        secondButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        
        view.addSubview(secondGrid)
        secondGrid.pinTop(to: secondLabel.bottomAnchor, 20)
        secondGrid.pinHorizontal(to: view, 20)

        secondGrid.configure(
            headerLeft: "26.10.2025  00:00",
            headerRight: "Выезд из РБ",
            rows: [
                .init(iconSystemName: "car.fill", valueText: "0"),
                .init(iconSystemName: "bus.fill", valueText: "0"),
                .init(iconSystemName: "truck.box.fill", valueText: "0")
            ]
        )
    }
    
    //MARK: - Objc
    @objc
    private func calendarButtonTapped() {
        interactor.loadCalendarView(request: Model.LoadMainTable.Request())
    }
    
    
    //MARK: - Present func
    public func presentCalendarSheet() {
        let sheet = CalendarBottomSheetView()
        sheet.onPick = { [weak self] date in
            let df = DateFormatter()
            df.dateFormat = "dd.MM.yyyy"
            self?.presentCalendarTable(date: date)
            
        }
        sheet.onClose = { [weak self] in
            self?.calendarSheet = nil
        }

        calendarSheet = sheet
        sheet.show(in: view)
    }
    
    public func presentCalendarTable(date: Date) {
        let table = CalendarTable()
        table.onClose = { [weak self] in
            self?.calendarTableView = nil
        }

        table.onShareTap = { [weak self] vc in
            self!.present(vc, animated: true)
        }
        calendarTableView = table
        table.show(in: view)
    }
}

