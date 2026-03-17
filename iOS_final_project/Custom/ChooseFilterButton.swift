//
//  ChooseFilterButton.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 18.02.26.
//

import UIKit

final class ChooseFilterButton: UIView {

    // MARK: - Callback
    var onTapAll: (() -> Void)?
    var onTapFirst: (() -> Void)?
    var onTapSecond: (() -> Void)?
    var onTapThird: (() -> Void)?
    var onTapFourth: (() -> Void)?
    var onTapFifth: (() -> Void)?
    var onTapSix: (() -> Void)?
    var onTapSeven: (() -> Void)?

    // MARK: - Style
    enum Constants {
        static let mainColor: UIColor = UIColor(hex: "#DB8C42") ?? .orange
        static let backgroundColor: UIColor = UIColor(hex: "#141414") ?? .black
        static let chooserBGColor: UIColor = UIColor(hex: "#353535") ?? .gray
        
        static let textColor: UIColor = .black
        static let fontName: String = "InriaSans-Bold"
        
        static let cornerRadius: CGFloat = 17
        static let height: CGFloat = 52
        static let horizontalPadding: CGFloat = 18
        static let rightWidth: CGFloat = 50
        
        static let dividerWidth: CGFloat = 5
        
        static let titleLabelWidth: CGFloat = 160
        
        static let filterWidth: CGFloat = titleLabelWidth + dividerWidth + rightWidth
        static let filterHeight: CGFloat = 33
        
        static let menuCorner: CGFloat = 24
        static let menuize: CGFloat = 64
        static let menuOpenedWidth: CGFloat = 280
        static let buttonHeight: CGFloat = 30
        static let buttonSpacing: CGFloat = 12
        
        static let stackTop : CGFloat = 10
        static let topInset: CGFloat = 20
        static let innerLeftRight: CGFloat = 15
    }

    // MARK: - Fields
    public var choosenSection: String = "Нет данных"
    
    public let titleLabel = UILabel()
    public let rightButton = UIButton(type: .system)
    private let divider = UIView()
    private let choosesPanel: UIView = {
        let v = UIView()
        v.backgroundColor = Constants.chooserBGColor
        v.layer.cornerRadius = Constants.menuCorner
        v.clipsToBounds = true
        v.alpha = 0
        return v
    }()
    private var chooses : [UIButton] = []
    private var menuWidthConstraint: NSLayoutConstraint?
    private var menuHeightConstraint: NSLayoutConstraint?
    private let stack = UIStackView()
    private var isOpen = false
    private let headerContainer = UIView()
    
    private var neededAdditions: String?
    private var fontScale: CGFloat = 17

    
    // MARK: - Livecycle
    init(title: String, fontSize: CGFloat, chooses: [String], needed: String = "all_needed") {
        super.init(frame: .zero)
        fontScale = fontSize
        neededAdditions = needed
        configureButtons(chooses: chooses)
        configureUI(title: title)
        configureConstraints()
        setupActions()
        setClosedState(animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureButtons(chooses: [String]) {
        for  title in chooses {
            self.chooses.append(ChooseFilterButton.makeItem(title: title))
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) {
            return true
        }

        guard isOpen else { return false }

        let pointInPanel = choosesPanel.convert(point, from: self)
        return choosesPanel.bounds.contains(pointInPanel)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let result = super.hitTest(point, with: event) {
            return result
        }

        guard isOpen else { return nil }

        let pointInPanel = choosesPanel.convert(point, from: self)
        return choosesPanel.hitTest(pointInPanel, with: event)
    }
    
    // MARK: - Configure
    private func configureUI(title: String) {
        clipsToBounds = false
        
        addSubview(headerContainer)
        headerContainer.pinTop(to: topAnchor)
        headerContainer.pinLeft(to: leadingAnchor)
        headerContainer.pinRight(to: trailingAnchor)
        headerContainer.setHeight(Constants.filterHeight)

        headerContainer.layer.cornerRadius = Constants.cornerRadius
        headerContainer.clipsToBounds = true
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(divider)
        headerContainer.addSubview(rightButton)
        
        setHeight(Constants.filterHeight)
        setWidth(Constants.filterWidth)

        titleLabel.text = title
        titleLabel.textColor = Constants.textColor
        titleLabel.font = UIFont(name: Constants.fontName, size: fontScale)
        titleLabel.numberOfLines = 2
        titleLabel.isUserInteractionEnabled = false
        titleLabel.backgroundColor = Constants.mainColor
        titleLabel.textAlignment = .center

        divider.backgroundColor = Constants.backgroundColor

        rightButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        rightButton.tintColor = Constants.textColor
        rightButton.contentHorizontalAlignment = .center
        rightButton.contentVerticalAlignment = .center
        rightButton.backgroundColor = Constants.mainColor
        
        addSubview(choosesPanel)
        choosesPanel.pinTop(to: self, 30)
        choosesPanel.pinRight(to: self, 0)

        menuWidthConstraint = choosesPanel.setWidth(Constants.menuize)
        menuHeightConstraint = choosesPanel.setHeight(Constants.menuize)

        stack.axis = .vertical
        stack.spacing = Constants.buttonSpacing
        stack.alignment = .fill
        stack.distribution = .fillEqually

        choosesPanel.addSubview(stack)
        stack.pinTop(to: choosesPanel.topAnchor, Constants.stackTop)
        stack.pinLeft(to: choosesPanel, Constants.innerLeftRight)
        stack.pinRight(to: choosesPanel, Constants.innerLeftRight)

        for (index, _) in chooses.enumerated() {
            chooses[index].setHeight(Constants.buttonHeight)
            stack.addArrangedSubview(chooses[index])
        }
        
    }

    private func configureConstraints() {
        
        rightButton.pinTop(to: topAnchor)
        rightButton.pinBottom(to: bottomAnchor)
        rightButton.pinRight(to: trailingAnchor)
        rightButton.setWidth( Constants.rightWidth)
        
        divider.pinTop(to: topAnchor)
        divider.pinBottom(to: bottomAnchor)
        divider.pinRight(to: rightButton.leadingAnchor)
        divider.setWidth(Constants.dividerWidth)
        
        titleLabel.pinTop(to: topAnchor)
        titleLabel.pinBottom(to: bottomAnchor)
        titleLabel.pinRight(to: divider.leadingAnchor)
        titleLabel.setWidth(Constants.titleLabelWidth)

    }
    
    private func setupActions() {
        switch(neededAdditions) {
        case "all_needed":
            chooses[0].addTarget(self, action: #selector(tapAll), for: .touchUpInside)
            chooses[1].addTarget(self, action: #selector(tapFirst), for: .touchUpInside)
            chooses[2].addTarget(self, action: #selector(tapSecond), for: .touchUpInside)
            
        case "all_not_needed":
            choosesPanel.pinCenterX(to: self)
            if (chooses.count == 2) {
                chooses[0].addTarget(self, action: #selector(tapFirst), for: .touchUpInside)
                chooses[1].addTarget(self, action: #selector(tapSecond), for: .touchUpInside)
            } else if (chooses.count == 4) {
                chooses[0].addTarget(self, action: #selector(tapFirst), for: .touchUpInside)
                chooses[1].addTarget(self, action: #selector(tapSecond), for: .touchUpInside)
                chooses[2].addTarget(self, action: #selector(tapThird), for: .touchUpInside)
                chooses[3].addTarget(self, action: #selector(tapFourth), for: .touchUpInside)
            }
        case "with_others":
            choosesPanel.pinCenterX(to: self)
            chooses[0].addTarget(self, action: #selector(tapFirst), for: .touchUpInside)
            chooses[1].addTarget(self, action: #selector(tapSecond), for: .touchUpInside)
            chooses[2].addTarget(self, action: #selector(tapThird), for: .touchUpInside)
            chooses[3].addTarget(self, action: #selector(tapFourth), for: .touchUpInside)
            chooses[4].addTarget(self, action: #selector(tapFifth), for: .touchUpInside)
            chooses[5].addTarget(self, action: #selector(tapSix), for: .touchUpInside)
            chooses[6].addTarget(self, action: #selector(tapSeven), for: .touchUpInside)
        
        default:
            choosesPanel.isHidden = true
        }
        
        rightButton.addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }
    

    func setChevron(isOpen: Bool) {
        let name = isOpen ? "chevron.up" : "chevron.down"
        rightButton.setImage(UIImage(systemName: name), for: .normal)
    }
    
    @objc func toggle() {
        isOpen ? close() : open()
    }
    
    
    func open() {
        guard let superview else { return }

        isOpen = true
        choosesPanel.alpha = 1

        let openedHeight =
                CGFloat(chooses.count) * (Constants.buttonHeight + Constants.buttonSpacing) + Constants.topInset

        let centerOffsetY = (bounds.height - openedHeight) / 2
        

        menuWidthConstraint?.constant = Constants.menuOpenedWidth
        menuHeightConstraint?.constant = openedHeight

        
        let maxY = frame.maxY + openedHeight
        if maxY > superview.bounds.height {
            choosesPanel.transform = CGAffineTransform(
                        translationX: 0,
                        y: centerOffsetY - 20
                    )
        } else {
            choosesPanel.transform = .identity
        }

        superview.bringSubviewToFront(self)
        superview.layoutIfNeeded()

        chooses.forEach {
            $0.alpha = 1
            $0.transform = .identity
        }
    }

    func close() {
        guard let superview else { return }
        
        isOpen = false
        menuWidthConstraint?.constant = Constants.menuize
        menuHeightConstraint?.constant = Constants.menuize
        self.choosesPanel.alpha = 0
        
        superview.layoutIfNeeded()

    }
    
    private func setClosedState(animated: Bool) {
        isOpen = false
        choosesPanel.alpha = 0
        chooses.forEach { $0.alpha = 0 }
    }

    
    // MARK: - Item style
    private static func makeItem(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.86, green: 0.56, blue: 0.23, alpha: 1)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        return button
    }

    // MARK: - taps
    @objc private func tapAll() {
        titleLabel.text = "Все"
        onTapAll?()
        close()
    }
    
    @objc private func tapFirst(_ sender: UIButton) {
        choosenSection = sender.currentTitle ?? ""
        titleLabel.text = choosenSection
        onTapFirst?()
        close()
    }
    
    @objc private func tapSecond(_ sender: UIButton) {
        choosenSection = sender.currentTitle ?? ""
        titleLabel.text = choosenSection
        onTapSecond?()
        close()
    }
    
    @objc private func tapThird(_ sender: UIButton) {
        choosenSection = sender.currentTitle ?? ""
        titleLabel.text = choosenSection
        onTapThird?()
        close()
    }
    
    @objc private func tapFourth(_ sender: UIButton) {
        choosenSection = sender.currentTitle ?? ""
        titleLabel.text = choosenSection
        onTapFourth?()
        close()
    }
    
    @objc private func tapFifth(_ sender: UIButton) {
        choosenSection = sender.currentTitle ?? ""
        titleLabel.text = choosenSection
        onTapFifth?()
        close()
    }
    
    @objc private func tapSix(_ sender: UIButton) {
        choosenSection = sender.currentTitle ?? ""
        titleLabel.text = choosenSection
        onTapSix?()
        close()
    }
    @objc private func tapSeven(_ sender: UIButton) {
        choosenSection = sender.currentTitle ?? ""
        titleLabel.text = choosenSection
        onTapSeven?()
        close()
    }
    
}
