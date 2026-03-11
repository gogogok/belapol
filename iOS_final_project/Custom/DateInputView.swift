//
//  DateInputView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 10.03.26.
//

import UIKit

final class DateInputView: UIView {
    
    enum Constants {
        static let backgroundColor = UIColor(hex: "#DB8C42")!
        static let textColor: UIColor = .black
        static let cornerRadius: CGFloat = 5
        
        static let fontName = "InriaSans-Bold"
        static let fontSize: CGFloat = 17
        
        static let height: CGFloat = 25
        static let horizontalInset: CGFloat = 14
    }
    
    private let textField = UITextField()
    private let datePicker = UIDatePicker()
    
    var onDateChanged: ((Date) -> Void)?
    
    var selectedDate: Date? {
        didSet {
            updateText()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupPicker()
        updateText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = Constants.backgroundColor
        layer.cornerRadius = Constants.cornerRadius
        clipsToBounds = true
        
        addSubview(textField)
        setHeight(Constants.height)
        
        textField.pinTop(to: topAnchor)
        textField.pinBottom(to: bottomAnchor)
        textField.pinLeft(to: leadingAnchor, Constants.horizontalInset)
        textField.pinRight(to: trailingAnchor, Constants.horizontalInset)
        
        textField.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        textField.textColor = Constants.textColor
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.tintColor = Constants.textColor
        textField.attributedPlaceholder = NSAttributedString(
            string: "_ _ . _ _ . _ _ _ _",
            attributes: [
                .foregroundColor: Constants.textColor
            ]
        )
    }
    
    private func setupPicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ru_RU")
        
        textField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let cancel = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelTapped))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Готово", style: .prominent, target: self, action: #selector(doneTapped))
        
        toolbar.items = [cancel, flexible, done]
        textField.inputAccessoryView = toolbar
    }
    
    private func updateText() {
        guard let selectedDate else {
            textField.text = nil
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        textField.text = formatter.string(from: selectedDate)
    }
    
    @objc private func cancelTapped() {
        textField.text = nil
        textField.resignFirstResponder()
    }
    
    @objc private func doneTapped() {
        selectedDate = datePicker.date
        onDateChanged?(datePicker.date)
        textField.resignFirstResponder()
    }
    
    func setDate(_ date: Date) {
        selectedDate = date
        datePicker.date = date
    }
}
