import UIKit

final class AddTicketViewController: UIViewController {
    
    typealias Model = AddTicketModel
    
    //MARK: - Constants
    private enum Constants {
        static let fatalError: String = "Ошибка создания"
        static let backgroundColor: UIColor = UIColor(hex: "#141414") ?? .black
        
        static let buttonHeight: CGFloat = 150
        static let buttonWidth: CGFloat = 170
        static let buttonLeft: CGFloat = -15
        static let catButtonTop: CGFloat = -40
        
        static let fontName = "InriaSans-Bold"
        static let fontSize: CGFloat = 13
        
        static let catRight: CGFloat = -90
        static let catBottom: CGFloat = -180
        static let catHeight: CGFloat = 400
        static let catWidth: CGFloat = 200
        static let catWRotate: CGFloat = 0
        
        static let stations: [String] = ["Минск", "Варшава"]
        static let points: [String] = ["Брест", "Берестовица", "Каменный лог", "Бенякони"]
        static let drivers: [String] = ["Ecolines", "Минсктранс", "Рич Бай", "Визиттур", "Интеркарс", "ПКС Гданьск", "Другой"]
        
        static let addButtonTitle: String = "Добавить билет"
        static let addButtonWidth: CGFloat = 150
        static let addButtonHeight: CGFloat = 40
        static let addButtonBottomToCat: CGFloat = -55
        
        static let mainViewCornerRadius: CGFloat = 20
        static let mainViewBorderWidth: CGFloat = 1
        static let mainViewHorizontalInset: CGFloat = 40
        static let mainViewBottomInset: CGFloat = 20
        
        static let dateTitle: String = "Дата выезда"
        static let fromTimeTitle: String = "Время выезда"
        static let toTimeTitle: String = "Время приезда"
        
        static let titleLabelWidth: CGFloat = 140
        static let titleLabelHeight: CGFloat = 25
        
        static let fromStationTitle: String = "Место отправления"
        static let toStationTitle: String = "Место прибытия"
        static let pointTitle: String = "Пункт пересечения границы"
        static let driverTitle: String = "Выбрать перевозчика"
        
        static let chooseFilterNeededAllNotNeeded: String = "all_not_needed"
        static let chooseFilterNeededWithOthers: String = "with_others"
        
        static let mainViewTopInset: CGFloat = 10
        static let mainViewLeftInset: CGFloat = 10
        static let labelToFieldSpacing: CGFloat = 20
        static let verticalSpacingSmall: CGFloat = 10
        static let verticalSpacingMedium: CGFloat = 20
        
        static let emptyString: String = ""
        static let defaultFromTime: String = "00:00"
        static let defaultToTime: String = "23:59"
        static let timeSeparator: String = " - "
        
        static let dateFormat: String = "dd.MM.yyyy"
    }
    
    //MARK: - Fields
    
    var interactor: AddTicketBusinessLogic
    public var onTicketAdded: ((TicketsVM) -> Void)?
    
    private let catButton: CatBackButton = CatBackButton()
    
    private let cat: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cat_belapol")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let addButton: BasicButtonView = BasicButtonView(
        label: Constants.addButtonTitle,
        width: Constants.addButtonWidth,
        height: Constants.addButtonHeight
    )
    
    private let mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.mainViewCornerRadius
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = Constants.mainViewBorderWidth
        view.backgroundColor = Constants.backgroundColor
        return view
    }()
    
    private let dateTextLable: BasicLabelView = BasicLabelView(
        label: Constants.dateTitle,
        width: Constants.titleLabelWidth,
        height: Constants.titleLabelHeight
    )
    
    private let dateLabel: DateInputView = DateInputView()
    
    private let fromTime: TimeInputView = TimeInputView()
    private let fromTimeTextLable: BasicLabelView = BasicLabelView(
        label: Constants.fromTimeTitle,
        width: Constants.titleLabelWidth,
        height: Constants.titleLabelHeight
    )
    
    private let toTime: TimeInputView = TimeInputView()
    private let toTimeTextLable: BasicLabelView = BasicLabelView(
        label: Constants.toTimeTitle,
        width: Constants.titleLabelWidth,
        height: Constants.titleLabelHeight
    )
    
    private let fromStationFilter: ChooseFilterButton = ChooseFilterButton(
        title: Constants.fromStationTitle,
        fontSize: Constants.fontSize,
        chooses: Constants.stations,
        needed: Constants.chooseFilterNeededAllNotNeeded
    )
    
    private let toStationFilter: ChooseFilterButton = ChooseFilterButton(
        title: Constants.toStationTitle,
        fontSize: Constants.fontSize,
        chooses: Constants.stations,
        needed: Constants.chooseFilterNeededAllNotNeeded
    )
    
    private let pointFilter: ChooseFilterButton = ChooseFilterButton(
        title: Constants.pointTitle,
        fontSize: Constants.fontSize,
        chooses: Constants.points,
        needed: Constants.chooseFilterNeededAllNotNeeded
    )
    
    private let chooseDriverFilter: ChooseFilterButton = ChooseFilterButton(
        title: Constants.driverTitle,
        fontSize: Constants.fontSize,
        chooses: Constants.drivers,
        needed: Constants.chooseFilterNeededWithOthers
    )
    
    //MARK: - Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK: - Lyfecycle
    init(interactor: AddTicketBusinessLogic) {
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
        configureAddButton()
        configureMainView()
    }
    
    private func configureBackground() {
        view.backgroundColor = Constants.backgroundColor
        
        view.addSubview(cat)
        cat.clipsToBounds = true
        cat.setWidth(Constants.catWidth)
        cat.setHeight(Constants.catHeight)
        cat.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Constants.catBottom)
        cat.pinCenterX(to: view)
        cat.transform = CGAffineTransform(rotationAngle: Constants.catWRotate * .pi / 180)
    }
    
    private func configureCatButton() {
        view.addSubview(catButton)
        catButton.setHeight(Constants.buttonHeight)
        catButton.setWidth(Constants.buttonWidth)
        catButton.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.catButtonTop)
        catButton.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor, Constants.buttonLeft)
        catButton.isUserInteractionEnabled = true
        catButton.addTarget(self, action: #selector(finish), for: .touchUpInside)
    }
    
    private func configureAddButton() {
        view.addSubview(addButton)
        addButton.pinCenterX(to: view)
        addButton.pinBottom(to: cat.topAnchor, Constants.addButtonBottomToCat)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func configureMainView() {
        view.addSubview(mainView)
        mainView.pinTop(to: catButton.bottomAnchor)
        mainView.pinHorizontal(to: view, Constants.mainViewHorizontalInset)
        mainView.pinBottom(to: addButton.topAnchor, Constants.mainViewBottomInset)
        
        mainView.addSubview(dateLabel)
        mainView.addSubview(dateTextLable)
        mainView.addSubview(fromTime)
        mainView.addSubview(fromTimeTextLable)
        mainView.addSubview(toTime)
        mainView.addSubview(toTimeTextLable)
        mainView.addSubview(fromStationFilter)
        mainView.addSubview(toStationFilter)
        mainView.addSubview(pointFilter)
        mainView.addSubview(chooseDriverFilter)
        
        dateTextLable.pinLeft(to: mainView.leadingAnchor, Constants.mainViewLeftInset)
        dateTextLable.pinTop(to: mainView.topAnchor, Constants.mainViewTopInset)
        dateTextLable.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        
        dateLabel.pinLeft(to: dateTextLable.trailingAnchor, Constants.labelToFieldSpacing)
        dateLabel.pinTop(to: mainView.topAnchor, Constants.mainViewTopInset)
        
        fromTimeTextLable.pinLeft(to: mainView.leadingAnchor, Constants.mainViewLeftInset)
        fromTimeTextLable.pinTop(to: dateTextLable.bottomAnchor, Constants.verticalSpacingSmall)
        fromTimeTextLable.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        
        fromTime.pinLeft(to: fromTimeTextLable.trailingAnchor, Constants.labelToFieldSpacing)
        fromTime.pinTop(to: dateTextLable.bottomAnchor, Constants.verticalSpacingSmall)
        
        toTimeTextLable.pinLeft(to: mainView.leadingAnchor, Constants.mainViewLeftInset)
        toTimeTextLable.pinTop(to: fromTimeTextLable.bottomAnchor, Constants.verticalSpacingSmall)
        toTimeTextLable.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        
        toTime.pinLeft(to: toTimeTextLable.trailingAnchor, Constants.labelToFieldSpacing)
        toTime.pinTop(to: fromTimeTextLable.bottomAnchor, Constants.verticalSpacingSmall)
        
        fromStationFilter.pinTop(to: toTime.bottomAnchor, Constants.verticalSpacingMedium)
        fromStationFilter.pinCenterX(to: mainView)
        
        toStationFilter.pinTop(to: fromStationFilter.bottomAnchor, Constants.verticalSpacingSmall)
        toStationFilter.pinCenterX(to: mainView)
        
        pointFilter.pinTop(to: toStationFilter.bottomAnchor, Constants.verticalSpacingSmall)
        pointFilter.pinCenterX(to: mainView)
        
        chooseDriverFilter.pinTop(to: pointFilter.bottomAnchor, Constants.verticalSpacingSmall)
        chooseDriverFilter.pinCenterX(to: mainView)
    }
    
    public func finishAddingTicket(vm: Model.LoadAddTicket.ViewModel) {
        onTicketAdded?(vm.ticket)
        dismiss(animated: true)
    }
    
    @objc
    public func finish() {
        dismiss(animated: true)
    }
    
    @objc
    private func addButtonTapped() {
        interactor.loadSaveTicket(request: Model.LoadAddTicket.Request(ticket: createTicket()))
    }
    
    private func createTicket() -> TicketsVM {
        let fromTimeText = fromTime.textField.text == Constants.emptyString
        ? Constants.defaultFromTime
        : fromTime.textField.text
        
        let toTimeText = toTime.textField.text == Constants.emptyString
        ? Constants.defaultToTime
        : toTime.textField.text
        
        let dateText = dateLabel.textField.text
        let date: String
        
        if let dateText, !dateText.isEmpty, dateText != Constants.emptyString {
            date = dateText
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = Constants.dateFormat
            date = formatter.string(from: Date())
        }
        
        return TicketsVM(
            id: UUID(),
            title: chooseDriverFilter.choosenSection,
            stationFrom: fromStationFilter.choosenSection,
            stationTo: toStationFilter.choosenSection,
            point: pointFilter.choosenSection,
            date: date,
            time: (fromTimeText ?? Constants.defaultFromTime) + Constants.timeSeparator + (toTimeText ?? Constants.defaultToTime),
            image: ImageMapping.image(bus: chooseDriverFilter.choosenSection),
            ticketURL: nil,
            fromAddress: fromStationFilter.choosenSection,
            toAddress: toStationFilter.choosenSection
        )
    }
}
