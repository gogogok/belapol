//
//  CloseButton.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 21.02.26.
//

import UIKit

final class CloseButton: UIButton {

    enum Constants {
        static let size = CGSize(width: 280, height: 140)
        static let closeSize = CGSize(width: 55, height: 44)
        static let closeCornerRadius: CGFloat = 12
        static let closeButtonColor = UIColor.black
    }

    private let backImageView = UIImageView()
    private let xBackgroundView = UIView()
    private let xImageView = UIImageView()

    init(backImage: UIImage?) {
        super.init(frame: .zero)

        setWidth(Constants.size.width)
        setHeight(Constants.size.height)

        backImageView.image = backImage
        backImageView.contentMode = .scaleAspectFit
        backImageView.transform = CGAffineTransform(rotationAngle: .pi)

        addSubview(backImageView)
        backImageView.pin(to: self)

        xBackgroundView.backgroundColor = Constants.closeButtonColor
        xBackgroundView.layer.cornerRadius = Constants.closeCornerRadius
        xBackgroundView.isUserInteractionEnabled = false

        addSubview(xBackgroundView)
        xBackgroundView.setWidth(Constants.closeSize.width)
        xBackgroundView.setHeight(Constants.closeSize.height)
        xBackgroundView.pinCenterY(to: self)
        xBackgroundView.pinCenterX(to: self, 15)

        xImageView.image = UIImage(systemName: "xmark")
        xImageView.tintColor = .white
        xImageView.contentMode = .center
        xImageView.isUserInteractionEnabled = false

        xBackgroundView.addSubview(xImageView)
        xImageView.pin(to: xBackgroundView, 0)

        isExclusiveTouch = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
