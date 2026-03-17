//
//  CalendarBottomSheetView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 21.02.26.
//

import UIKit

final class CalendarBottomSheetView: UIView {
    
    enum Constants {
        static let cornerRadius: CGFloat = 28
        static let sideInset: Double = 16
        static let topInset: Double = 18
       
        static let titleSize: CGFloat = 20
        
        static let closeWidth: Double = 55
        static let closeHeight: Double = 40
        static let closeCornerRadius: Double = 12
        static let closeButtonColor: UIColor = UIColor(hex: "#191919") ?? .black
        
        static let sheetHeight: Double = 500
        
        static let closeButtonImageName: String = "back_button"
        static let closeButtonImageRotate: CGFloat = 180
    }
    
    var onPick: ((Date) -> Void)?
    var onClose: (() -> Void)?
    
    private let dimView: UIControl = {
        let v = UIControl()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v.alpha = 0
        return v
    }()
    
    private let sheet = UIView()
    private let titleLabel = UILabel()
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
        
        
        titleLabel.text = "Выберите дату"
        titleLabel.font = .systemFont(ofSize: Constants.titleSize, weight: .bold)
        titleLabel.textColor = .label
        
        sheet.addSubview(titleLabel)
        titleLabel.pinTop(to: sheet, Constants.topInset)
        titleLabel.pinLeft(to: sheet, 24)
        
        
        addSubview(closePawButton)
        
        closePawButton.pinCenterY(to: titleLabel, 4)
        closePawButton.pinRight(to: safeAreaLayoutGuide.trailingAnchor, -60)
        
        
        sheet.addSubview(calendarView)
        calendarView.pinTop(to: titleLabel.bottomAnchor, 25)
        calendarView.pinLeft(to: sheet, 16)
        calendarView.pinRight(to: sheet, 16)
        calendarView.pinBottom(to: sheet.safeAreaLayoutGuide.bottomAnchor)
        
        calendarView.calendar = Calendar(identifier: .gregorian)
        calendarView.locale = Locale(identifier: "ru_RU")
        
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        
    }
    
    private func setupActions() {
        dimView.addTarget(self, action: #selector(didTapDim), for: .touchUpInside)
        closePawButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }
    
    @objc private func didTapDim() {
        hide()
    }
    
    @objc private func didTapClose() {
        hide()
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

extension CalendarBottomSheetView: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate,
                       didSelectDate dateComponents: DateComponents?) {
        guard let comps = dateComponents,
              let date = Calendar.current.date(from: comps) else { return }
        
        onPick?(date)
        hide()
    }
}
