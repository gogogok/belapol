//
//  ChooseFilterButton.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 18.02.26.
//

import UIKit

final class ChooseFilterButton: UIView {

    // MARK: - Callback
    var onRightTap: (() -> Void)?

    // MARK: - Style
    enum Constants {
        static let mainColor: UIColor = UIColor(hex: "#DB8C42")!
        static let backgroundColor: UIColor = UIColor(hex: "#141414")!
        
        static let textColor: UIColor = .black
        static let fontName: String = "Inter-SemiBold"
        static let fontSize : CGFloat = 12
        
        static let cornerRadius: CGFloat = 17
        static let height: CGFloat = 52
        static let horizontalPadding: CGFloat = 18
        static let rightWidth: CGFloat = 50
        
        static let dividerWidth: CGFloat = 5
        
        static let titleLabelWidth: CGFloat = 160
        
        static let filterWidth: CGFloat = titleLabelWidth + dividerWidth + rightWidth
        static let filterHeight: CGFloat = 33
    }

    // MARK: - Fields
    private let titleLabel = UILabel()
    private let rightButton = UIButton(type: .system)
    private let divider = UIView()

    
    // MARK: - Livecycle
    init(title: String) {
        super.init(frame: .zero)
        configureUI(title: title)
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    private func configureUI(title: String) {
        layer.cornerRadius = Constants.cornerRadius
        clipsToBounds = true
        
        setHeight(Constants.filterHeight)
        setWidth(Constants.filterWidth)

        titleLabel.text = title
        titleLabel.textColor = Constants.textColor
        titleLabel.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        titleLabel.numberOfLines = 1
        titleLabel.isUserInteractionEnabled = false
        titleLabel.backgroundColor = Constants.mainColor
        titleLabel.textAlignment = .center

        divider.backgroundColor = Constants.backgroundColor

        rightButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        rightButton.tintColor = Constants.textColor
        //rightButton.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
        rightButton.contentHorizontalAlignment = .center
        rightButton.contentVerticalAlignment = .center
        rightButton.backgroundColor = Constants.mainColor

        addSubview(titleLabel)
        addSubview(divider)
        addSubview(rightButton)
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

    @objc private func rightTapped() {
        onRightTap?()
    }

}
