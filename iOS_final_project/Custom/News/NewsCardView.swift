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

    }

    // MARK: - UI
    private let bgImageView: UIImageView = {
        let imView = UIImageView()
        imView.contentMode = .scaleAspectFill
        imView.clipsToBounds = true
        imView.alpha = 0.4
        return imView
    }()

    private let glassView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemChromeMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()

    private let titleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 20, weight: .heavy)
        title.textColor = .white
        title.numberOfLines = 2
        title.setContentCompressionResistancePriority(.required, for: .vertical)
        return title
    }()

    private let dateLabel: UILabel = {
        let date = UILabel()
        date.font = .italicSystemFont(ofSize: 12)
        date.textColor = .white
        return date
    }()

    private let subtitleLabel: UILabel = {
        let subTitle = UILabel()
        subTitle.font = .systemFont(ofSize: 11, weight: .regular)
        subTitle.textColor = UIColor.white.withAlphaComponent(0.95)
        subTitle.numberOfLines = 3
        return subTitle
    }()

    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
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

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Configure
    private func configureUI() {
        layer.cornerRadius = 15
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

        glassView.pinTop(to: topAnchor, 100)
        glassView.pinHorizontal(to: self, 9)
        glassView.pinBottom(to: bottomAnchor, 8)

        titleLabel.pinTop(to: topAnchor, 10)
        titleLabel.pinHorizontal(to: self, 11)
        

        dateLabel.pinTop(to: titleLabel.bottomAnchor, 14)
        dateLabel.pinLeft(to: leadingAnchor, 11)

        subtitleLabel.pin(to: glassView, 10)

        setHeight(180)
    }

    func configure(
        title: String,
        dateText: String,
        subtitle: String,
        image: UIImage,
    ) {
        titleLabel.text = title
        dateLabel.text = dateText
        subtitleLabel.text = subtitle
        bgImageView.image = image
    }
}
