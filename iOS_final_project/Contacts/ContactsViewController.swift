import UIKit

final class ContactsViewController: UIViewController {
    
    typealias Model = ContactsModel
    
    //MARK: - Constants
    private enum Constants {
        static let fatalError: String = "Ошибка создания"
        
        static let infoBackgroundColor: UIColor = UIColor(hex: "#E9E8E8")!
        
        static let buttonHeight : CGFloat = 150
        static let buttonHWidth : CGFloat = 170
        static let buttonLeft : CGFloat = -15
        
        static let backgroundColor: UIColor = UIColor(hex: "#141414")!
        
        static let catRight: CGFloat = -100
        static let catTop: CGFloat = -150
        static let catHeight: CGFloat = 400
        static let catWidth: CGFloat = 200
        static let catWRotate: CGFloat = 270
        
        static let contactsBorderLabelName: String = "Контакты границы"
        static let contactsBorderLabelWidth: CGFloat = 210
        static let contactsBorderLabelHeight: CGFloat = 30
        static let contactsBorderLabelLeft: CGFloat = 15
        static let contactsBorderLabelTop: CGFloat = 5
        
        static let contactsBorderDescription: String = "Круглосуточный телефон \"горячей линии\" по вопросам пересечения Государственной границы: +375 17 329 18 98 " +
        "\n\n" + "Круглосуточный телефон доверия службы собственной безопасности: +375 17 224 50 08"
        
        static let contactsBorderDescriptionLabelWidth: CGFloat = 210
        static let contactsBorderDescriptionHeight: CGFloat = 150
        static let contactsBorderDescriptionLabelLeft: CGFloat = 20
        static let contactsBorderDescriptionLabelTop: CGFloat = 10
        static let contactsBorderDescriptionLabelTopFontSize: CGFloat = 18
        
        static let contactsBorderCarrierLabel: String = "Контакты перевозчиков"
        static let contactsBorderCarrierLabelWidth: CGFloat = 230
        
        static let contactsBorderCarrierDescriptionLabel: String = "INTERCARS поддержка \nt.me/intercars_support \n\nEASY LINES \nTelegram: @EasyLines_official \nЗвонки / Viber / WhatsApp: +48 725 244 486 \nKIMAX SP ZOO \ntel 690666285 \n\nTERRALine Sp zoo \nbiuro@terraline.pl; +48 697 170 375 \n\n\"Автобусный парк №2 г.Лида\" ОАО \"Гроднооблавтотранс\"\n+375154547676\n\nЧУП \"Авео-бел\" +375 29 167 5550\n\nОАО «Пинский автобусный парк»\n114, +375165 614444, +375165627249\n\nBS OOO \"РКЭкспресс\" +375 298 70-77-51\n\n B-BUS\n +48 736 854 504 :\n kontakt@busbus.pl\n+48735537777 (звонки и телеграмм)\n\nФилиал «Автобусный парк № 5» ГП «Минсктранс»\nвайбер +375297002038\n\nПКС Гданьск\n+48 783 933 333, +48 514 990 375 (диспетчер)\nOpenline +380674003631\n\nIP BayerTrans\n+375296437022 (телеграмм)\n\nBS ЧТУП \"Трасса Е 95\"\n+375445142142 (телеграмм)\n\nEcolines\n+375293533060, +375445044286\n\nМинсктранс\n+375297002038(телеграмм)\n+375298635131( ТОЛЬКО СООБЩЕНИЯ БЕЗ ЗВОНКОВ!!!!)\n\nМинский автовокзал\n114, 8(801)100-40-14, 8(017)25-11-411,8(017)328-56-05\n\n ИП Ершов АА\n+375 (29) 150-74-66\n+375 (29) 237-91-33\n+375 (44) 720-49-08\n Ул Новая,6, Гомель, Беларусь"
        static let contactsBorderCarrierDescriptionLabelWidth: CGFloat = 210
        static let contactsBorderCarrierDescriptionLabelHeight: CGFloat = 1100
        

    }
    
    //MARK: - Fields
    
    var interactor : ContactsBusinessLogic
    
    let cat: UIImageView = {
        let label = UIImageView()
        label.image = UIImage(named: "cat_belapol")
        label.contentMode = .scaleAspectFit
        label.tintColor = .white
        return label
    }()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let catButton = CatBackButton()
    let pawMenu = PawMenuView()
    let contactsBorderLabel = BasicLabelView(label: Constants.contactsBorderLabelName, width: Constants.contactsBorderLabelWidth, height: Constants.contactsBorderLabelHeight)
    let contactsBorderDescriptionLable = BasicLabelView(label: Constants.contactsBorderDescription, width: Constants.contactsBorderDescriptionLabelWidth, height: Constants.contactsBorderDescriptionHeight)
    let contactsCarrierLabel = BasicLabelView(label: Constants.contactsBorderCarrierLabel, width: Constants.contactsBorderCarrierLabelWidth, height: Constants.contactsBorderLabelHeight)
    let contactsCarrierDescriptionLabel = BasicLabelView(label: Constants.contactsBorderCarrierDescriptionLabel, width: Constants.contactsBorderCarrierDescriptionLabelWidth, height: Constants.contactsBorderCarrierDescriptionLabelHeight)
        
    
    //MARK: - Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    //MARK: - Lyfecycle
    init(interactor: ContactsBusinessLogic) {
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
        setupScroll()
        configureInformationLabel()
        view.bringSubviewToFront(pawMenu)
        
    }
    
    private func configureBackground() {
        view.backgroundColor = Constants.backgroundColor
        
        view.addSubview(cat)
        
        cat.transform = CGAffineTransform(rotationAngle: Constants.catWRotate * .pi / 180)
        cat.clipsToBounds = true
        
        cat.setWidth(Constants.catWidth)
        cat.setHeight(Constants.catHeight)
        
        cat.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.catTop)
        cat.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, Constants.catRight)
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
        
    }
    
    private func configureInformationLabel() {
        contentView.addSubview(contactsBorderLabel)
        contactsBorderLabel.pinTop(to: contentView.topAnchor, Constants.contactsBorderLabelTop)
        contactsBorderLabel.pinLeft(to: contentView.leadingAnchor, Constants.contactsBorderLabelLeft)
        
        contentView.addSubview(contactsBorderDescriptionLable)
        
        contactsBorderDescriptionLable.lineBreakMode = .byWordWrapping
        contactsBorderDescriptionLable.textAlignment = .left
        contactsBorderDescriptionLable.font.withSize(Constants.contactsBorderDescriptionLabelTopFontSize)
        contactsBorderDescriptionLable.backgroundColor = Constants.infoBackgroundColor
        
        contactsBorderDescriptionLable.pinTop(to: contactsBorderLabel.bottomAnchor, Constants.contactsBorderDescriptionLabelTop)
        contactsBorderDescriptionLable.pinHorizontal(to: contentView, Constants.contactsBorderDescriptionLabelLeft)
        
        contentView.addSubview(contactsCarrierLabel)
        contactsCarrierLabel.pinTop(to: contactsBorderDescriptionLable.bottomAnchor, Constants.contactsBorderDescriptionLabelTop)
        contactsCarrierLabel.pinLeft(to: contentView.leadingAnchor, Constants.contactsBorderLabelLeft)
        
        contentView.addSubview(contactsCarrierDescriptionLabel)
        contactsCarrierDescriptionLabel.lineBreakMode = .byWordWrapping
        contactsCarrierDescriptionLabel.textAlignment = .left
        contactsCarrierDescriptionLabel.font.withSize(Constants.contactsBorderDescriptionLabelTopFontSize)
        contactsCarrierDescriptionLabel.backgroundColor = Constants.infoBackgroundColor
        
        contactsCarrierDescriptionLabel.pinTop(to: contactsCarrierLabel.bottomAnchor, Constants.contactsBorderDescriptionLabelTop)
        contactsCarrierDescriptionLabel.pinHorizontal(to: contentView, Constants.contactsBorderDescriptionLabelLeft)
        contactsCarrierDescriptionLabel.pinBottom(to: contentView.bottomAnchor, 24)
    }
    
    private func setupScroll() {
        view.addSubview(scrollView)
        scrollView.pinTop(to: pawMenu.bottomAnchor, 20)
        scrollView.pinBottom(to: view.bottomAnchor)
        scrollView.pinHorizontal(to: view)


        scrollView.addSubview(contentView)
        contentView.pinTop(to: scrollView.topAnchor)
        contentView.pinBottom(to: scrollView.bottomAnchor)
        contentView.pinHorizontal(to: scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    //MARK: - Present func
    func displayView(vc: UIViewController) {
        guard let nav = navigationController else { return }
        
        var stack = nav.viewControllers
        stack[stack.count - 1] = vc
        nav.setViewControllers(stack, animated: true)
    }
}

