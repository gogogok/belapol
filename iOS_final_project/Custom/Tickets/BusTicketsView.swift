//
//  BaseTicketsView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 25.02.26.
//

import UIKit

final class BusTicketsView: UIView {

    var onDeleteSwipe: (() -> Void)?
    var onTitleTap: (() -> Void)?
    var onFromTap: (() -> Void)?
    var onToTap: (() -> Void)?

    private var initialCenter: CGPoint = .zero

    //MARK: - Constants
    private enum Constants {
        static let mainFontSize: CGFloat = 20
        static let fontName: String = "InriaSans-Bold"

        static let titleFontSize: CGFloat = 15
        static let titleFontWeight: UIFont.Weight = .heavy

        static let fromFontSize: CGFloat = 12
        static let toFontSize: CGFloat = 11
        static let pointFontSize: CGFloat = 10

        static let dateFontSize: CGFloat = mainFontSize - 2
        static let timeFontSize: CGFloat = mainFontSize

        static let textColor: UIColor = .white
        static let borderColor: CGColor = UIColor.white.cgColor

        static let cornerRadius: CGFloat = 15
        static let borderWidth: CGFloat = 2
        static let imageAlpha: CGFloat = 0.4

        static let titleTop: CGFloat = 10
        static let titleLeft: CGFloat = 10
        static let titleWidth: CGFloat = 200

        static let fromTop: CGFloat = 10
        static let labelsLeft: CGFloat = 10
        static let fromWidth: CGFloat = 270
        static let toWidth: CGFloat = 270
        static let toTop: CGFloat = 2

        static let dateTop: CGFloat = 10
        static let dateRight: CGFloat = 10
        static let dateWidth: CGFloat = 100

        static let timeTop: CGFloat = 5
        static let timeRight: CGFloat = 10
        static let timeWidth: CGFloat = 90

        static let pointBottom: CGFloat = 10
        static let pointHorizontalInset: CGFloat = 10

        static let cardHeight: CGFloat = 125

        static let deleteThreshold: CGFloat = -100
        static let animationDuration: TimeInterval = 0.2
    }

    // MARK: - UI
    private let bgImageView: UIImageView = {
        let imView = UIImageView()
        imView.contentMode = .scaleAspectFill
        imView.clipsToBounds = true
        imView.alpha = Constants.imageAlpha
        imView.layer.borderColor = Constants.borderColor
        imView.layer.cornerRadius = Constants.cornerRadius
        imView.layer.borderWidth = Constants.borderWidth
        return imView
    }()

    private let titleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: Constants.titleFontSize, weight: Constants.titleFontWeight)
        title.textColor = Constants.textColor
        title.numberOfLines = 2
        title.setContentCompressionResistancePriority(.required, for: .vertical)
        title.setWidth(Constants.titleWidth)
        return title
    }()

    private let fromLabel: UILabel = {
        let from = UILabel()
        from.font = .systemFont(ofSize: Constants.fromFontSize)
        from.textColor = Constants.textColor
        from.setWidth(Constants.fromWidth)
        from.numberOfLines = 2
        return from
    }()

    private let toLabel: UILabel = {
        let to = UILabel()
        to.font = .systemFont(ofSize: Constants.toFontSize)
        to.textColor = Constants.textColor
        to.numberOfLines = 1
        to.setWidth(Constants.toWidth)
        return to
    }()

    private let pointLabel: UILabel = {
        let point = UILabel()
        point.font = .italicSystemFont(ofSize: Constants.pointFontSize)
        point.textColor = Constants.textColor
        return point
    }()

    private let dateLabel: UILabel = {
        let date = UILabel()
        date.font = UIFont(name: Constants.fontName, size: Constants.dateFontSize)
        date.textAlignment = .right
        date.textColor = Constants.textColor
        date.numberOfLines = 3
        date.setWidth(Constants.dateWidth)
        return date
    }()

    private let timeLabel: UILabel = {
        let time = UILabel()
        time.font = UIFont(name: Constants.fontName, size: Constants.timeFontSize)
        time.textAlignment = .right
        time.textColor = Constants.textColor
        time.numberOfLines = 3
        time.setWidth(Constants.timeWidth)
        return time
    }()

    // MARK: - Lyfecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupGesture()
        setUpActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
        setupGesture()
        setUpActions()
    }

    // MARK: - Configure
    private func configureUI() {
        layer.cornerRadius = Constants.cornerRadius
        clipsToBounds = true

        addSubview(bgImageView)
        addSubview(titleLabel)
        addSubview(fromLabel)
        addSubview(toLabel)
        addSubview(pointLabel)
        addSubview(dateLabel)
        addSubview(timeLabel)

        bgImageView.pin(to: self)

        titleLabel.pinTop(to: topAnchor, Constants.titleTop)
        titleLabel.pinLeft(to: leadingAnchor, Constants.titleLeft)

        fromLabel.pinTop(to: titleLabel.bottomAnchor, Constants.fromTop)
        toLabel.pinTop(to: fromLabel.bottomAnchor, Constants.toTop)
        fromLabel.pinLeft(to: leadingAnchor, Constants.labelsLeft)
        toLabel.pinLeft(to: leadingAnchor, Constants.labelsLeft)

        dateLabel.pinTop(to: topAnchor, Constants.dateTop)
        dateLabel.pinRight(to: trailingAnchor, Constants.dateRight)

        timeLabel.pinTop(to: dateLabel.bottomAnchor, Constants.timeTop)
        timeLabel.pinRight(to: trailingAnchor, Constants.timeRight)

        pointLabel.pinBottom(to: bottomAnchor, Constants.pointBottom)
        pointLabel.pinHorizontal(to: self, Constants.pointHorizontalInset)

        setHeight(Constants.cardHeight)
    }

    func configure(
        title: String,
        stationFrom: String,
        stationTo: String,
        point: String,
        date: String,
        time: String,
        image: UIImage?
    ) {
        titleLabel.text = title
        fromLabel.text = stationFrom
        toLabel.text = stationTo
        pointLabel.text = point
        dateLabel.text = date
        timeLabel.text = time
        bgImageView.image = image
    }

    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(pan)
        isUserInteractionEnabled = true
    }

    private func setUpActions() {
        titleLabel.isUserInteractionEnabled = true
        fromLabel.isUserInteractionEnabled = true
        toLabel.isUserInteractionEnabled = true

        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTitleTap)))
        fromLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFromTap)))
        toLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleToTap)))
    }

    @objc
    private func handleSwipeLeft() {
        onDeleteSwipe?()
    }

    @objc
    private func handleTitleTap() {
        onTitleTap?()
    }

    @objc
    private func handleFromTap() {
        onFromTap?()
    }

    @objc
    private func handleToTap() {
        onToTap?()
    }

    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)

        switch gesture.state {
        case .began:
            initialCenter = center

        case .changed:
            if translation.x < 0 {
                transform = CGAffineTransform(translationX: translation.x, y: 0)
            }

        case .ended, .cancelled:
            let shouldDelete = translation.x < Constants.deleteThreshold

            if shouldDelete {
                UIView.animate(withDuration: Constants.animationDuration, animations: {
                    self.transform = CGAffineTransform(translationX: -self.bounds.width, y: 0)
                    self.alpha = 0
                }) { _ in
                    self.onDeleteSwipe?()
                }
            } else {
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.transform = .identity
                }
            }

        default:
            break
        }
    }
}
