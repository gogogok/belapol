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
        static let fontName: String = "InriaSans-Bold"
        static let fontSize: CGFloat = 17
        static let descriptionFontSize: CGFloat = 13
        static let buttonFontSize: CGFloat = 14

        static let textColor: UIColor = .white
        static let borderColor: CGColor = UIColor.white.cgColor

        static let backgroundImageName: String = "car_share_background"
        static let backgroundAlpha: CGFloat = 0.4

        static let cornerRadius: CGFloat = 15
        static let borderWidth: CGFloat = 2

        static let dateTopInset: CGFloat = 10
        static let leadingInset: CGFloat = 10

        static let timeTopInset: CGFloat = 3
        static let descriptionTopInset: CGFloat = 20

        static let dateWidth: CGFloat = 150
        static let timeWidth: CGFloat = 100
        static let descriptionWidth: CGFloat = 230

        static let buttonRightInset: CGFloat = 20
        static let buttonBottomInset: CGFloat = 20
        static let buttonWidth: CGFloat = 100
        static let buttonHeight: CGFloat = 30
        static let buttonTitle: String = "Подробнее"

        static let viewHeight: CGFloat = 125

        static let dateNumberOfLines: Int = 3
        static let timeNumberOfLines: Int = 3
        static let descriptionNumberOfLines: Int = 2
        static let descriptionLineSpacing: CGFloat = 6
    }
    
    // MARK: - UI
    private let bgImageView: UIImageView = {
        let imView = UIImageView()
        imView.contentMode = .scaleAspectFill
        imView.clipsToBounds = true
        imView.alpha = Constants.backgroundAlpha
        imView.layer.borderColor = Constants.borderColor
        imView.layer.cornerRadius = Constants.cornerRadius
        imView.layer.borderWidth = Constants.borderWidth
        imView.image = UIImage(named: Constants.backgroundImageName)
        return imView
    }()

    private let dateLabel: UILabel = {
        let date = UILabel()
        date.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        date.textColor = Constants.textColor
        date.numberOfLines = Constants.dateNumberOfLines
        date.setWidth(Constants.dateWidth)
        return date
    }()
    
    private let timeLabel: UILabel = {
        let time = UILabel()
        time.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        time.textColor = Constants.textColor
        time.numberOfLines = Constants.timeNumberOfLines
        time.setWidth(Constants.timeWidth)
        return time
    }()
    
    private let descriptionLabel: UILabel = {
        let description = UILabel()
        description.font = UIFont(name: Constants.fontName, size: Constants.descriptionFontSize)
        description.textColor = Constants.textColor
        description.numberOfLines = Constants.descriptionNumberOfLines
        description.setWidth(Constants.descriptionWidth)
        return description
    }()
    
    private let showMoreButton: BasicButtonView = BasicButtonView(
        label: Constants.buttonTitle,
        width: Constants.buttonWidth,
        height: Constants.buttonHeight
    )

    // MARK: - Lifecycle
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
        layer.cornerRadius = Constants.cornerRadius
        clipsToBounds = true

        addSubview(bgImageView)
        addSubview(dateLabel)
        addSubview(timeLabel)
        addSubview(descriptionLabel)
        addSubview(showMoreButton)

        bgImageView.pin(to: self)

        dateLabel.pinTop(to: topAnchor, Constants.dateTopInset)
        dateLabel.pinLeft(to: leadingAnchor, Constants.leadingInset)

        timeLabel.pinTop(to: dateLabel.bottomAnchor, Constants.timeTopInset)
        timeLabel.pinLeft(to: leadingAnchor, Constants.leadingInset)

        descriptionLabel.pinTop(to: timeLabel.bottomAnchor, Constants.descriptionTopInset)
        descriptionLabel.pinLeft(to: leadingAnchor, Constants.leadingInset)

        showMoreButton.pinRight(to: trailingAnchor, Constants.buttonRightInset)
        showMoreButton.pinBottom(to: bottomAnchor, Constants.buttonBottomInset)
        showMoreButton.layer.cornerRadius = Constants.cornerRadius
        showMoreButton.titleLabel?.font = UIFont(name: Constants.fontName, size: Constants.buttonFontSize)
        showMoreButton.addTarget(self, action: #selector(showMoreTapped), for: .touchUpInside)

        setHeight(Constants.viewHeight)
    }

    func configure(date: String, time: String, description: String, userName: String, nickname: String) {
        dateLabel.text = date
        timeLabel.text = time
        descriptionLabel.text = description
        makeSectionTitle(label: descriptionLabel)
    }
    
    private func makeSectionTitle(label: UILabel) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = Constants.descriptionLineSpacing

        let attributed = NSAttributedString(
            string: label.text ?? "",
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
