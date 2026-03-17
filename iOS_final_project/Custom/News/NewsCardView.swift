//
//  NewsCardView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 25.02.26.
//

import UIKit

final class NewsCardView: UIView {

    //MARK: - Constants
    private enum Constants {
        static let textColor: UIColor = .white
        static let subtitleColor: UIColor = UIColor.white.withAlphaComponent(0.95)
        static let dateFont: UIFont = .italicSystemFont(ofSize: 12)
        static let subtitleFont: UIFont = .systemFont(ofSize: 11, weight: .regular)
        static let valueFont = UIFont(name: "InriaSans-Bold", size: 20) ?? .boldSystemFont(ofSize: 20)

        static let strokeWidth: CGFloat = 5
        static let strokeColor: UIColor = .black

        static let cornerRadius: CGFloat = 15
        static let borderWidth: CGFloat = 2
        static let borderColor: UIColor = UIColor.white.withAlphaComponent(0.8)

        static let glassTop: CGFloat = 100
        static let glassHorizontal: CGFloat = 9
        static let glassBottom: CGFloat = 8

        static let titleTop: CGFloat = 10
        static let titleHorizontal: CGFloat = 11

        static let dateTop: CGFloat = 14
        static let dateLeft: CGFloat = 11

        static let subtitleInset: CGFloat = 10

        static let cardHeight: CGFloat = 180

        static let imageAlpha: CGFloat = 1
    }

    // MARK: - UI
    private let bgImageView: UIImageView = {
        let imView = UIImageView()
        imView.contentMode = .scaleAspectFill
        imView.clipsToBounds = true
        imView.alpha = Constants.imageAlpha
        return imView
    }()

    private let glassView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemChromeMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.cornerRadius
        return view
    }()

    private let titleLabel: UILabel = {
        let title = UILabel()
        title.numberOfLines = 2
        title.setContentCompressionResistancePriority(.required, for: .vertical)
        return title
    }()

    private let dateLabel: UILabel = {
        let date = UILabel()
        date.font = Constants.dateFont
        date.textColor = Constants.textColor
        return date
    }()

    private let subtitleLabel: UILabel = {
        let subTitle = UILabel()
        subTitle.font = Constants.subtitleFont
        subTitle.textColor = Constants.subtitleColor
        subTitle.numberOfLines = 3
        return subTitle
    }()

    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.borderWidth = Constants.borderWidth
        view.layer.borderColor = Constants.borderColor.cgColor
        view.isUserInteractionEnabled = false
        return view
    }()


    // MARK: - Lyfecycle
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
        addSubview(glassView)
        addSubview(borderView)
        addSubview(titleLabel)
        addSubview(dateLabel)

        let content = glassView.contentView
        content.addSubview(subtitleLabel)

        bgImageView.pin(to: self)
        borderView.pin(to: self)

        glassView.pinTop(to: topAnchor, Constants.glassTop)
        glassView.pinHorizontal(to: self, Constants.glassHorizontal)
        glassView.pinBottom(to: bottomAnchor, Constants.glassBottom)

        titleLabel.pinTop(to: topAnchor, Constants.titleTop)
        titleLabel.pinHorizontal(to: self, Constants.titleHorizontal)

        dateLabel.pinTop(to: titleLabel.bottomAnchor, Constants.dateTop)
        dateLabel.pinLeft(to: leadingAnchor, Constants.dateLeft)

        subtitleLabel.pin(to: glassView, Constants.subtitleInset)

        setHeight(Constants.cardHeight)
    }

    func configure(
        title: String,
        dateText: String,
        subtitle: String,
        image: UIImage?
    ) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Constants.valueFont,
            .foregroundColor: Constants.textColor,
            .strokeColor: Constants.strokeColor,
            .strokeWidth: -Constants.strokeWidth
        ]

        titleLabel.attributedText = NSAttributedString(string: title, attributes: attributes)
        dateLabel.text = dateText
        subtitleLabel.text = subtitle
        bgImageView.image = image
    }
}
