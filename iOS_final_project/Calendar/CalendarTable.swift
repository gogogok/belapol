//
//  CalendarTable.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 21.02.26.
//

import UIKit

final class CalendarTable: UIView {
    
    enum Constants {
        static let cornerRadius: CGFloat = 28
        static let sideInset: Double = 20
        static let topInset: Double = 20
       
        static let titleSize: CGFloat = 20
        
        static let closeWidth: Double = 55
        static let closeHeight: Double = 40
        static let closeCornerRadius: Double = 12
        static let closeButtonColor: UIColor = UIColor(hex: "#191919")!
        
        static let sheetHeight: Double = 500
        
        static let shareButtonSize: CGFloat = 50

        static let closeButtonImageName: String = "back_button"
        static let closeButtonImageRotate: CGFloat = 180
    }
    
    var onClose: (() -> Void)?
    var onShareTap: ((UIActivityViewController) -> Void)?
    
    private let dimView: UIControl = {
        let v = UIControl()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v.alpha = 0
        return v
    }()
    
    private let sheet = UIView()
    private let shareButton = UIButton(type: .system)
    private let closePawButton = CloseButton(backImage: UIImage(named: Constants.closeButtonImageName))
    
    private let calendarView = UICalendarView()
    
    private var sheetBottomConstraint: NSLayoutConstraint?
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        
        addSubview(dimView)
        dimView.pin(to: self)
        
        addSubview(sheet)
        sheet.backgroundColor = .systemBackground
        sheet.layer.cornerRadius = Constants.cornerRadius
        sheet.clipsToBounds = true
        
        sheet.pinLeft(to: self, Constants.sideInset)
        sheet.pinRight(to: self, Constants.sideInset)
        sheet.setHeight(Constants.sheetHeight)
        
        sheetBottomConstraint = sheet.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.sheetHeight)
        sheetBottomConstraint?.isActive = true
        
        
        shareButton.setWidth(Constants.shareButtonSize)
        shareButton.setHeight(Constants.shareButtonSize)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .black
        shareButton.imageView?.setWidth(Constants.shareButtonSize)
        shareButton.imageView?.setHeight(Constants.shareButtonSize)
        
        sheet.addSubview(shareButton)
        shareButton.pinTop(to: sheet, Constants.topInset)
        shareButton.pinLeft(to: sheet, Constants.sideInset)
        
        
        addSubview(closePawButton)
        
        closePawButton.pinCenterY(to: shareButton, 4)
        closePawButton.pinRight(to: safeAreaLayoutGuide.trailingAnchor, -60)
        
    }
    
    private func setupActions() {
        dimView.addTarget(self, action: #selector(didTapDim), for: .touchUpInside)
        closePawButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    @objc private func didTapDim() {
        hide()
    }
    
    @objc private func didTapClose() {
        hide()
    }
    
    @objc private func shareButtonTapped() {
        let text = "Допустим"
        let url = URL(string: "https://www.youtube.com/")!
        
        let activityVC = UIActivityViewController(
            activityItems: [text, url],
            applicationActivities: nil
        )
        
        self.onShareTap?(activityVC)
    }
    
    func show(in parent: UIView) {
        parent.addSubview(self)
        pin(to: parent, 0)
        parent.layoutIfNeeded()
        
        sheetBottomConstraint?.constant = -8
        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.dimView.alpha = 1
            parent.layoutIfNeeded()
        }
    }
    
    func hide() {
        guard let parent = superview else { return }
        
        sheetBottomConstraint?.constant = Constants.sheetHeight
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn]) {
            self.dimView.alpha = 0
            parent.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
            self.onClose?()
        }
    }
}

