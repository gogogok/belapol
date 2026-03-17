//
//  TimeInputView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 10.03.26.
//

import UIKit

final class TimeInputView: UIView {
    
    enum Constants {
        static let backgroundColor = UIColor(hex: "#DB8C42") ?? .orange
        static let textColor: UIColor = .black
        static let cornerRadius: CGFloat = 5
        
        static let fontName = "InriaSans-Bold"
        static let fontSize: CGFloat = 17
        
        static let height: CGFloat = 25
        static let horizontalInset: CGFloat = 14
    }
    
    public let textField = UITextField()
    private let timePicker = UIDatePicker()
    
    var onTimeChanged: ((Date) -> Void)?
    
    var selectedTime: Date? {
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
        textField.tintColor = .clear
        textField.attributedPlaceholder = NSAttributedString(
            string: "_ _ : _ _",
            attributes: [
                .foregroundColor: Constants.textColor
            ]
        )
    }
    
    private func setupPicker() {
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.locale = Locale(identifier: "ru_RU")
        
        textField.inputView = timePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let cancel = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelTapped))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Готово", style: .prominent, target: self, action: #selector(doneTapped))
        
        toolbar.items = [cancel, flexible, done]
        textField.inputAccessoryView = toolbar
    }
    
    private func updateText() {
        guard let selectedTime else {
            textField.text = nil
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        textField.text = formatter.string(from: selectedTime)
    }
    
    @objc private func cancelTapped() {
        textField.text = nil
        textField.resignFirstResponder()
    }
    
    @objc private func doneTapped() {
        selectedTime = timePicker.date
        onTimeChanged?(timePicker.date)
        textField.resignFirstResponder()
    }
    
    func setTime(_ date: Date) {
        selectedTime = date
        timePicker.date = date
    }
}
