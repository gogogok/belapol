//
//  CarShareView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 7.03.26.
//

import UIKit

final class CarShareView: UIView {
    
    var onTapShowMore: (() -> Void)?

    //MARK: - Constants
    private enum Constants {
        static let fontSize: CGFloat = 17
        static let descriptionFontSize: CGFloat = 13
        static let fontName: String = "InriaSans-Bold"
    }
    
    // MARK: - UI
    private let bgImageView: UIImageView = {
        let imView = UIImageView()
        imView.contentMode = .scaleAspectFill
        imView.clipsToBounds = true
        imView.alpha = 0.4
        imView.layer.borderColor = UIColor.white.cgColor
        imView.layer.cornerRadius = 15
        imView.layer.borderWidth = 2
        imView.image = UIImage(named: "car_share_background")
        return imView
    }()

    
    private let dateLabel: UILabel = {
        let date = UILabel()
        date.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        date.textColor = .white
        date.numberOfLines = 3
        date.setWidth(150)
        return date
    }()
    
    private let timeLabel: UILabel = {
        let date = UILabel()
        date.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        date.textColor = .white
        date.numberOfLines = 3
        date.setWidth(100)
        return date
    }()
    
    private let descriptionLabel: UILabel = {
        let description = UILabel()
        description.font = UIFont(name: Constants.fontName, size: Constants.descriptionFontSize)
        description.textColor = .white
        description.numberOfLines = 2
        
        description.setWidth(230)
        
        return description
    }()
    
    private let showMoreButton : BasicButtonView = BasicButtonView(label: "Подробнее", width: 100, height: 30)

    // MARK: - Lyfecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Configure
    private func configureUI() {
        layer.cornerRadius = 15
        clipsToBounds = true

        addSubview(bgImageView)
        addSubview(dateLabel)
        addSubview(timeLabel)
        addSubview(descriptionLabel)
        addSubview(showMoreButton)

        bgImageView.pin(to: self)
        
        
        dateLabel.pinTop(to: topAnchor, 10)
        dateLabel.pinLeft(to: leadingAnchor, 10)
        
        timeLabel.pinTop(to: dateLabel.bottomAnchor, 3)
        timeLabel.pinLeft(to: leadingAnchor, 10)
        
        descriptionLabel.pinTop(to: timeLabel.bottomAnchor, 20)
        descriptionLabel.pinLeft(to: leadingAnchor, 10)
        
        showMoreButton.pinRight(to: trailingAnchor, 20)
        showMoreButton.pinBottom(to: bottomAnchor, 20)
        showMoreButton.layer.cornerRadius = 15
        showMoreButton.titleLabel?.font = UIFont(name: Constants.fontName, size: 14)
        showMoreButton.addTarget(self, action: #selector(showMoreTapped), for: .touchUpInside)
        
        setHeight(125)
    }

    func configure (date: String, time: String, description: String, userName: String, nickname: String) {
        dateLabel.text = date
        timeLabel.text = time
        descriptionLabel.text = description
        makeSectionTitle(label: descriptionLabel)
    }
    
    private func makeSectionTitle(label: UILabel) {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        
        let attributed = NSAttributedString(
            string: label.text!,
            attributes: [
                .paragraphStyle: paragraph
            ]
        )
        
        label.attributedText = attributed
    }
    
    @objc
    private func showMoreTapped() {
        onTapShowMore?()
    }
    
}

