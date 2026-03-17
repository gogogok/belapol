//
//  RidePostPopupView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 16.03.26.
//

import UIKit

final class RidePostPopupView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        static let dimAlpha: CGFloat = 0.45
        static let animationShowDuration: TimeInterval = 0.25
        static let animationHideDuration: TimeInterval = 0.2
        static let cardScale: CGFloat = 0.92
        
        static let cardCornerRadius: CGFloat = 26
        static let closeButtonCornerRadius: CGFloat = 28
        
        static let cardHorizontalInset: CGFloat = 16
        static let cardTopMinInset: CGFloat = 80
        static let cardBottomMinInset: CGFloat = 80
        static let cardHeight: CGFloat = 350
        
        static let closeButtonImageName: String = "back_button"
        static let closeButtonTopInset: CGFloat = 5
        static let closeButtonRightInset: CGFloat = -60
        
        static let nameTopInset: CGFloat = -5
        static let sideInsetLarge: CGFloat = 42
        static let sideInsetMedium: CGFloat = 32
        static let spacingNameToUsername: CGFloat = 22
        static let spacingUsernameToPost: CGFloat = 46
        static let bottomInset: CGFloat = 40
        
        static let closeIconPointSize: CGFloat = 18
        
        static let cardBackgroundColorHex : UIColor  = UIColor(hex: "#F3F3F3") ?? .white
        static let closeButtonBackgroundColorHex : UIColor  = UIColor(hex: "#111111") ?? .black
        
        static let nameFontName = "InriaSerif-Bold"
        static let usernameFontName = "InriaSerif-Bold"
        static let postFontName = "InriaSerif-Bold"
        
        static let nameFontSize: CGFloat = 20
        static let usernameFontSize: CGFloat = 18
        static let postFontSize: CGFloat = 16
    }
    
    // MARK: - Public
    var onClose: (() -> Void)?
    
    func configure(
        name: String,
        username: String,
        text: String
    ) {
        nameLabel.text = name
        usernameLabel.text = username
        postLabel.text = text
    }
    
    func show(in parentView: UIView) {
        parentView.addSubview(self)
        pin(to: parentView)
        
        alpha = 0
        parentView.layoutIfNeeded()
        
        cardView.transform = CGAffineTransform(scaleX: Constants.cardScale, y: Constants.cardScale)
        dimView.alpha = 0
        
        UIView.animate(withDuration: Constants.animationShowDuration) {
            self.alpha = 1
            self.dimView.alpha = 1
            self.cardView.transform = .identity
        }
    }
    
    func hide() {
        UIView.animate(withDuration: Constants.animationHideDuration, animations: {
            self.alpha = 0
            self.cardView.transform = CGAffineTransform(scaleX: Constants.cardScale, y: Constants.cardScale)
        }) { _ in
            self.removeFromSuperview()
            self.onClose?()
        }
    }
    
    // MARK: - UI
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(Constants.dimAlpha)
        return view
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.cardBackgroundColorHex
        view.layer.cornerRadius = Constants.cardCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    private let closePawButton = CloseButton(backImage: UIImage(named: Constants.closeButtonImageName))
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constants.nameFontName, size: Constants.nameFontSize)
            ?? .boldSystemFont(ofSize: Constants.nameFontSize)
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constants.usernameFontName, size: Constants.usernameFontSize)
            ?? .boldSystemFont(ofSize: Constants.usernameFontSize)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private let postLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constants.postFontName, size: Constants.postFontSize)
            ?? .boldSystemFont(ofSize: Constants.postFontSize)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    // MARK: - Configure
    private func configureUI() {
        backgroundColor = .clear
        
        addSubview(dimView)
        addSubview(cardView)
        
        cardView.addSubview(closePawButton)
        cardView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(postLabel)
        
        dimView.pin(to: self)
        
        cardView.pinHorizontal(to: self, Constants.cardHorizontalInset)
        cardView.pinCenterY(to: self)
        cardView.pinCenterX(to: self)
        cardView.setHeight(Constants.cardHeight)
        
        closePawButton.pinTop(to: cardView.topAnchor, Constants.closeButtonTopInset)
        closePawButton.pinRight(to: cardView.trailingAnchor, Constants.closeButtonRightInset)
        
        scrollView.pinTop(to: closePawButton.bottomAnchor, Constants.nameTopInset)
        scrollView.pinLeft(to: cardView)
        scrollView.pinRight(to: cardView)
        scrollView.pinBottom(to: cardView.bottomAnchor, Constants.bottomInset)
        
        contentView.pin(to: scrollView)
        contentView.pinWidth(to: scrollView.frameLayoutGuide.widthAnchor)
        
        nameLabel.pinTop(to: contentView)
        nameLabel.pinLeft(to: contentView, Constants.sideInsetLarge)
        nameLabel.pinRight(to: closePawButton.leadingAnchor, 16)
        
        usernameLabel.pinTop(to: nameLabel.bottomAnchor, Constants.spacingNameToUsername)
        usernameLabel.pinLeft(to: contentView, Constants.sideInsetLarge)
        usernameLabel.pinRight(to: contentView, Constants.sideInsetLarge)
        
        postLabel.pinTop(to: usernameLabel.bottomAnchor, Constants.spacingUsernameToPost)
        postLabel.pinLeft(to: contentView, Constants.sideInsetMedium)
        postLabel.pinRight(to: contentView, Constants.sideInsetMedium)
        postLabel.pinBottom(to: contentView, Constants.bottomInset)
        
        closePawButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        dimView.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        hide()
    }
    
    @objc private func backgroundTapped() {
        hide()
    }
}
