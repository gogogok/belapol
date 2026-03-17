//
//  ArchiveLoadingView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 13.03.26.
//

import UIKit

final class LoadingView: UIView {
    
    private enum Constants {
        static let backgroundAlpha: CGFloat = 0.45
        
        static let cardWidth: CGFloat = 220
        static let cardHeight: CGFloat = 190
        static let cardCornerRadius: CGFloat = 24
        
        static let iconSize: CGFloat = 64
        static let centerDotSize: CGFloat = 20
        static let ringLineWidth: CGFloat = 6
        static let ringStartAngle: CGFloat = -.pi / 2
        static let ringEndAngle: CGFloat = .pi * 1.3
        
        static let iconTopInset: Double = 28
        static let titleTopInset: Double = 20
        static let subtitleTopInset: Double = 8
        static let horizontalInset: Double = 16
        
        static let titleFontSize: CGFloat = 18
        static let subtitleFontSize: CGFloat = 14
        static let centerDotCornerRadius: CGFloat = 10
        
        static let showHideAnimationDuration: TimeInterval = 0.2
        static let rotationDuration: TimeInterval = 1.0
        static let pulseDuration: TimeInterval = 0.6
        static let pulseScale: CGFloat = 1.18
        
        static let titleText = "Загружаем данные"
        static let subtitleText = "Подождите чуть-чуть..."
        
        static let backgroundColor = UIColor.black.withAlphaComponent(backgroundAlpha)
        static let cardColor = UIColor(hex: "#1F1F1F") ?? .black
        static let accentColor = UIColor(hex: "#DB8C42") ?? .orange
        static let titleColor: UIColor = .white
        static let subtitleColor: UIColor = .lightGray
        
        static let rotationAnimationKey = "rotation"
        static let pulseAnimationKey = "pulse"
    }
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.backgroundColor
        return view
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.cardColor
        view.layer.cornerRadius = Constants.cardCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    private let iconContainer = UIView()
    
    private let spinningRing: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = Constants.accentColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = Constants.ringLineWidth
        layer.lineCap = .round
        return layer
    }()
    
    private let centerDot: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.accentColor
        view.layer.cornerRadius = Constants.centerDotCornerRadius
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleText
        label.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        label.textColor = Constants.titleColor
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.subtitleText
        label.font = .systemFont(ofSize: Constants.subtitleFontSize)
        label.textColor = Constants.subtitleColor
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSpinningRing()
    }
    
    func show(in parent: UIView) {
        parent.addSubview(self)
        pin(to: parent)
        
        UIView.animate(withDuration: Constants.showHideAnimationDuration) {
            self.alpha = 1
        }
        
        startAnimating()
    }
    
    func hide() {
        stopAnimating()
        
        UIView.animate(withDuration: Constants.showHideAnimationDuration, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    private func setupUI() {
        setupHierarchy()
        setupConstraints()
        setupAppearance()
    }
    
    private func setupHierarchy() {
        addSubview(dimView)
        addSubview(cardView)
        
        cardView.addSubview(iconContainer)
        iconContainer.layer.addSublayer(spinningRing)
        iconContainer.addSubview(centerDot)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
    }
    
    private func setupConstraints() {
        setupDimViewConstraints()
        setupCardViewConstraints()
        setupIconContainerConstraints()
        setupCenterDotConstraints()
        setupTitleLabelConstraints()
        setupSubtitleLabelConstraints()
    }
    
    private func setupDimViewConstraints() {
        dimView.pin(to: self)
    }
    
    private func setupCardViewConstraints() {
        cardView.pinCenter(to: self)
        cardView.setWidth(Constants.cardWidth)
        cardView.setHeight(Constants.cardHeight)
    }
    
    private func setupIconContainerConstraints() {
        iconContainer.pinTop(to: cardView.topAnchor, Constants.iconTopInset)
        iconContainer.pinCenterX(to: cardView.centerXAnchor)
        iconContainer.setWidth(Constants.iconSize)
        iconContainer.setHeight(Constants.iconSize)
    }
    
    private func setupCenterDotConstraints() {
        centerDot.pinCenter(to: iconContainer)
        centerDot.setWidth(Constants.centerDotSize)
        centerDot.setHeight(Constants.centerDotSize)
    }
    
    private func setupTitleLabelConstraints() {
        titleLabel.pinTop(to: iconContainer.bottomAnchor, Constants.titleTopInset)
        titleLabel.pinLeft(to: cardView.leadingAnchor, Constants.horizontalInset)
        titleLabel.pinRight(to: cardView.trailingAnchor, Constants.horizontalInset)
    }
    
    private func setupSubtitleLabelConstraints() {
        subtitleLabel.pinTop(to: titleLabel.bottomAnchor, Constants.subtitleTopInset)
        subtitleLabel.pinLeft(to: cardView.leadingAnchor, Constants.horizontalInset)
        subtitleLabel.pinRight(to: cardView.trailingAnchor, Constants.horizontalInset)
    }
    
    private func setupAppearance() {
        alpha = 0
    }
    
    private func layoutSpinningRing() {
        let ringFrame = CGRect(
            x: 0,
            y: 0,
            width: Constants.iconSize,
            height: Constants.iconSize
        )
        
        let center = CGPoint(
            x: ringFrame.midX,
            y: ringFrame.midY
        )
        
        let radius = Constants.iconSize / 2 - Constants.ringLineWidth
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: Constants.ringStartAngle,
            endAngle: Constants.ringEndAngle,
            clockwise: true
        )
        
        spinningRing.frame = ringFrame
        spinningRing.path = path.cgPath
    }
    
    private func startAnimating() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = Constants.rotationDuration
        rotation.repeatCount = .infinity
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
        spinningRing.add(rotation, forKey: Constants.rotationAnimationKey)
        
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = Constants.pulseScale
        pulse.duration = Constants.pulseDuration
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        centerDot.layer.add(pulse, forKey: Constants.pulseAnimationKey)
    }
    
    private func stopAnimating() {
        spinningRing.removeAnimation(forKey: Constants.rotationAnimationKey)
        centerDot.layer.removeAnimation(forKey: Constants.pulseAnimationKey)
    }
}
