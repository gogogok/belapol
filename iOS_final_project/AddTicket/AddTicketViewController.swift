import UIKit

final class AddTicketViewController: UIViewController {
    
    typealias Model = AddTicketModel
    
    //MARK: - Constants
    private enum Constants {
        static let fatalError: String = "Ошибка создания"
        static let backgroundColor: UIColor = UIColor(hex: "#141414")!
        
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
        
        static let stationsFrom : [String] = ["Минск Центральный", "Варшава Западная"]
    }
    
    //MARK: - Fields
    
    var interactor : AddTicketBusinessLogic
    
    private let catButton: CatBackButton = CatBackButton()
    private let cat: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cat_belapol")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let addButton : BasicButtonView = BasicButtonView(label: "Добавить билет", width: 150, height: 40)
    private let mainView: UIView  = {
        let view = UIView()
        
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = Constants.backgroundColor
        return view
    }()
    
    private let dateTextLable: BasicLabelView = BasicLabelView(label: "Дата выезда", width: 140, height: 25)
    private let dateLabel: DateInputView = DateInputView()
    
    private let fromTime : TimeInputView = TimeInputView()
    private let fromTimeTextLable: BasicLabelView = BasicLabelView(label: "Время выезда", width: 140, height: 25)
    
    private let toTime : TimeInputView = TimeInputView()
    private let toTimeTextLable: BasicLabelView = BasicLabelView(label: "Время приезда", width: 140, height: 25)
    
    private let fromStationFilter: ChooseFilterButton = ChooseFilterButton(title: "Вокзал отправления", chooses: Constants.stationsFrom)
    private let toStationFilter: ChooseFilterButton = ChooseFilterButton(title: "Вокзал прибытия", chooses: Constants.stationsFrom)
    private let pointFilter: ChooseFilterButton = ChooseFilterButton(title: "Пункт пересечения границы", chooses: Constants.stationsFrom)
    private let chooseDriverFilter: ChooseFilterButton = ChooseFilterButton(title: "Выбрать перевозчика", chooses: Constants.stationsFrom)
    
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
        catButton.isUserInteractionEnabled = false
    }
    
    private func configureAddButton() {
        view.addSubview(addButton)
        addButton.pinCenterX(to: view)
        addButton.pinBottom(to: cat.topAnchor, -55)
    }
    
    private func configureMainView() {
        view.addSubview(mainView)
        mainView.pinTop(to: catButton.bottomAnchor)
        mainView.pinHorizontal(to: view, 40)
        mainView.pinBottom(to: addButton.topAnchor, 20)
        
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
        
        dateTextLable.pinLeft(to: mainView.leadingAnchor, 10)
        dateTextLable.pinTop(to: mainView.topAnchor, 10)
        dateTextLable.font =  UIFont(name: Constants.fontName, size: Constants.fontSize)
        
        dateLabel.pinLeft(to: dateTextLable.trailingAnchor, 20)
        dateLabel.pinTop(to: mainView.topAnchor, 10)
        
        fromTimeTextLable.pinLeft(to: mainView.leadingAnchor, 10)
        fromTimeTextLable.pinTop(to: dateTextLable.bottomAnchor, 10)
        fromTimeTextLable.font =  UIFont(name: Constants.fontName, size: Constants.fontSize)
        
        fromTime.pinLeft(to: fromTimeTextLable.trailingAnchor, 20)
        fromTime.pinTop(to: dateTextLable.bottomAnchor, 10)
        
        toTimeTextLable.pinLeft(to: mainView.leadingAnchor, 10)
        toTimeTextLable.pinTop(to: fromTimeTextLable.bottomAnchor, 10)
        toTimeTextLable.font =  UIFont(name: Constants.fontName, size: Constants.fontSize)
        
        toTime.pinLeft(to: toTimeTextLable.trailingAnchor, 20)
        toTime.pinTop(to: fromTimeTextLable.bottomAnchor, 10)
        
        fromStationFilter.pinTop(to: toTime.bottomAnchor, 20)
        fromStationFilter.pinCenterX(to: mainView)
        fromStationFilter.titleLabel.font =  UIFont(name: Constants.fontName, size: Constants.fontSize)
        
        toStationFilter.pinTop(to: fromStationFilter.bottomAnchor, 10)
        toStationFilter.pinCenterX(to: mainView)
        toStationFilter.titleLabel.font =  UIFont(name: Constants.fontName, size: Constants.fontSize)
        
        pointFilter.pinTop(to: toStationFilter.bottomAnchor, 10)
        pointFilter.pinCenterX(to: mainView)
        pointFilter.titleLabel.font =  UIFont(name: Constants.fontName, size: Constants.fontSize)
        
        chooseDriverFilter.pinTop(to: pointFilter.bottomAnchor, 10)
        chooseDriverFilter.pinCenterX(to: mainView)
        chooseDriverFilter.titleLabel.font =  UIFont(name: Constants.fontName, size: Constants.fontSize)
        
    }

}

