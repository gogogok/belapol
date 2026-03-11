//
//  ChooseFilterButton.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 18.02.26.
//

import UIKit

final class ChooseFilterButton: UIView {

    // MARK: - Callback
    var onTapBrTr: (() -> Void)?
    var onTapBerBr: (() -> Void)?

    // MARK: - Style
    enum Constants {
        static let mainColor: UIColor = UIColor(hex: "#DB8C42")!
        static let backgroundColor: UIColor = UIColor(hex: "#141414")!
        
        static let textColor: UIColor = .black
        static let fontName: String = "InriaSans-Bold"
        static let fontSize : CGFloat = 17
        
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
    public let titleLabel = UILabel()
    private let rightButton = UIButton(type: .system)
    private let divider = UIView()
    private let choosesPanel: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.22, alpha: 1.0)
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

    
    // MARK: - Livecycle
    init(title: String, chooses: [String]) {
        super.init(frame: .zero)
        configureButtons(chooses: chooses)
        configureUI(title: title)
        configureConstraints()
        setupActions(title: title)
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
        titleLabel.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
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

        // stack
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
    
    private func setupActions(title: String) {
        switch(title) {
        case "Выбрать пункт":
            chooses[0].addTarget(self, action: #selector(tapBrTr), for: .touchUpInside)
            chooses[1].addTarget(self, action: #selector(tapBerBr), for: .touchUpInside)
            
        case "Установить фильтр":
            chooses[0].addTarget(self, action: #selector(tapBrTr), for: .touchUpInside)
            chooses[1].addTarget(self, action: #selector(tapBerBr), for: .touchUpInside)
            
        default:
            return
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

        menuWidthConstraint?.constant = Constants.menuOpenedWidth
        menuHeightConstraint?.constant = CGFloat(chooses.count) * (Constants.buttonHeight + Constants.buttonSpacing) + Constants.topInset

        chooses.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: -10)
        }

        superview.layoutIfNeeded()

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            superview.layoutIfNeeded()
        } completion: { _ in
            for (i, btn) in self.chooses.enumerated() {
                UIView.animate(withDuration: 0.22, delay: Double(i) * 0.04, options: [.curveEaseOut]) {
                    btn.alpha = 1
                    btn.transform = .identity
                }
            }
        }
    }

    func close() {
        guard let superview else { return }
        isOpen = false

        UIView.animate(withDuration: 0.12) {
            self.chooses.forEach { $0.alpha = 0 }
        }

        menuWidthConstraint?.constant = Constants.menuize
        menuHeightConstraint?.constant = Constants.menuize

        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn]) {
            superview.layoutIfNeeded()
        } completion: { _ in
            self.choosesPanel.alpha = 0
        }
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
    @objc private func tapBrTr() { onTapBrTr?() }
    @objc private func tapBerBr() { onTapBerBr?() }
    
}
