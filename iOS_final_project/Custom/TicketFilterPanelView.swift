//
//  TicketFilterPanelView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 15.03.26.
//

import UIKit

final class TicketFilterPanelView: UIView {
    
    struct FilterData {
        let date: Date?
        let departureTimeFrom: Date?
        let departureTimeTo: Date?
        let departurePlace: String?
        let arrivalPlace: String?
    }
    
    // MARK: - Callbacks
    var onApply: ((FilterData) -> Void)?
    var onReset: (() -> Void)?
    var onToggle: ((Bool) -> Void)?
    
    // MARK: - Constants
    private enum Constants {
        static let panelColor = UIColor(hex: "#353535") ?? .gray
        static let accentColor = UIColor(hex: "#DB8C42") ?? .orange
        static let clearColor = UIColor.clear
        
        static let fontSize: CGFloat = 14
        
        static let cornerRadius: CGFloat = 28
        static let topButtonHeight: CGFloat = 66
        
        static let sideInset: CGFloat = 18
        static let topInset: CGFloat = 18
        static let bottomInset: CGFloat = 18
        
        static let verticalSpacing: CGFloat = 14
        static let smallSpacing: CGFloat = 10
        
        static let applyButtonHeight: CGFloat = 42
        static let resetButtonHeight: CGFloat = 36
        
        static let dateLabelWidth: CGFloat = 75
        static let dateLabelHeight: CGFloat = 30
        
        static let smallLabelWidth: CGFloat = 33
        static let smallLabelHeight: CGFloat = 23
        
        static let sectionLabelWidth: CGFloat = 150
        static let sectionLabelHeight: CGFloat = 30
        
        static let contentTopInset: CGFloat = 12
        static let animationDuration: TimeInterval = 0.25
    }
    
    // MARK: - State
    private(set) var isExpanded = false
    
    // MARK: - Constraints
    private var contentHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI
    private let rootStack = UIStackView()
    private let contentContainer = UIView()
    private let contentStack = UIStackView()
    
    private let topFilterButton = ChooseFilterButton(
        title: "Установить фильтр",
        fontSize: Constants.fontSize,
        chooses: [],
        needed: "not_needed"
    )
    
    private let dateTitleLabel = BasicLabelView(
        label: "Дата",
        width: Constants.dateLabelWidth,
        height: Constants.dateLabelHeight
    )
    
    let dateInputView = DateInputView()
    
    private let timeTitleLabel = BasicLabelView(
        label: "Время выезда",
        width: Constants.sectionLabelWidth,
        height: Constants.sectionLabelHeight
    )
    
    private let fromLabel = BasicLabelView(
        label: "С",
        width: Constants.smallLabelWidth - 7,
        height: Constants.smallLabelHeight,
        left: 2,
        right: 2
    )
    
    let timeFromInputView = TimeInputView()
    
    private let toLabel = BasicLabelView(
        label: "По",
        width: Constants.smallLabelWidth,
        height: Constants.smallLabelHeight,
        left: 2,
        right: 2
    )
    
    let timeToInputView = TimeInputView()
    
    let departureButton = ChooseFilterButton(
        title: "Место отправления",
        fontSize: Constants.fontSize,
        chooses: ["Минск", "Варшава"],
        needed: "all_not_needed"
    )
    
    let arrivalButton = ChooseFilterButton(
        title: "Место прибытия",
        fontSize: Constants.fontSize,
        chooses: ["Минск", "Варшава"],
        needed: "all_not_needed"
    )
    
    private let applyButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        setupActions()
        updateExpandedState(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func collapse(animated: Bool = true) {
        guard isExpanded else { return }
        isExpanded = false
        updateExpandedState(animated: animated)
    }
    
    func expand(animated: Bool = true) {
        guard !isExpanded else { return }
        isExpanded = true
        updateExpandedState(animated: animated)
    }
    
    func toggle(animated: Bool = true) {
        isExpanded.toggle()
        updateExpandedState(animated: animated)
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = Constants.clearColor
        clipsToBounds = false
        
        rootStack.axis = .vertical
        rootStack.spacing = 0
        rootStack.alignment = .fill
        rootStack.distribution = .fill
        
        addSubview(rootStack)
        rootStack.pin(to: self)
        
        contentContainer.backgroundColor = Constants.panelColor
        contentContainer.layer.cornerRadius = Constants.cornerRadius
        contentContainer.clipsToBounds = true
        
        contentStack.axis = .vertical
        contentStack.spacing = Constants.verticalSpacing
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        
        contentContainer.addSubview(contentStack)
        contentStack.pinTop(to: contentContainer.topAnchor, Constants.contentTopInset)
        contentStack.pinLeft(to: contentContainer.leadingAnchor, Constants.sideInset)
        contentStack.pinRight(to: contentContainer.trailingAnchor, Constants.sideInset)
        contentStack.pinBottom(to: contentContainer.bottomAnchor, Constants.bottomInset)
        
        setupButtonsStyle()
        setupTopButton()
    }
    
    private func setupTopButton() {
        topFilterButton.setHeight(Constants.topButtonHeight)
        topFilterButton.layer.cornerRadius = Constants.cornerRadius
        topFilterButton.clipsToBounds = true
        
        topFilterButton.rightButton.addTarget(self, action: #selector(topFilterTapped), for: .touchUpInside)
    }
    
    private func setupButtonsStyle() {
        applyButton.setTitle("Применить", for: .normal)
        applyButton.backgroundColor = Constants.accentColor
        applyButton.setTitleColor(.black, for: .normal)
        applyButton.titleLabel?.font = UIFont(name: "InriaSans-Bold", size: 18)
        applyButton.layer.cornerRadius = 16
        applyButton.clipsToBounds = true
        applyButton.setHeight(Constants.applyButtonHeight)
        
        resetButton.setTitle("Сбросить", for: .normal)
        resetButton.backgroundColor = .clear
        resetButton.setTitleColor(Constants.accentColor, for: .normal)
        resetButton.titleLabel?.font = UIFont(name: "InriaSans-Bold", size: 16)
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = Constants.accentColor.cgColor
        resetButton.layer.cornerRadius = 16
        resetButton.clipsToBounds = true
        resetButton.setHeight(Constants.resetButtonHeight)
    }
    
    private func setupLayout() {
        departureButton.setHeight(33)
        arrivalButton.setHeight(33)
        
        let dateRow = makeHorizontalStack(spacing: Constants.smallSpacing)
        dateRow.addArrangedSubview(dateTitleLabel)
        dateRow.addArrangedSubview(dateInputView)
        
        let timeTitleRow = makeHorizontalStack(spacing: 0)
        timeTitleRow.alignment = .center
        timeTitleRow.addArrangedSubview(UIView())
        timeTitleRow.addArrangedSubview(timeTitleLabel)
        timeTitleRow.addArrangedSubview(UIView())
        
        let timeRow = makeHorizontalStack(spacing: Constants.smallSpacing)
        timeRow.addArrangedSubview(fromLabel)
        timeRow.addArrangedSubview(timeFromInputView)
        timeRow.addArrangedSubview(toLabel)
        timeRow.addArrangedSubview(timeToInputView)
        
        rootStack.addArrangedSubview(topFilterButton)
        rootStack.addArrangedSubview(contentContainer)
        
        contentStack.addArrangedSubview(dateRow)
        contentStack.addArrangedSubview(timeTitleRow)
        contentStack.addArrangedSubview(timeRow)
        contentStack.addArrangedSubview(departureButton)
        contentStack.addArrangedSubview(arrivalButton)
        contentStack.addArrangedSubview(applyButton)
        contentStack.addArrangedSubview(resetButton)
        
        contentHeightConstraint = contentContainer.heightAnchor.constraint(equalToConstant: 0)
        contentHeightConstraint?.isActive = true
    }
    
    private func setupActions() {
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc
    private func topFilterTapped() {
        toggle(animated: true)
    }
    
    @objc
    private func applyTapped() {
        let data = FilterData(
            date: dateInputView.selectedDate,
            departureTimeFrom: timeFromInputView.selectedTime,
            departureTimeTo: timeToInputView.selectedTime,
            departurePlace: normalizedSelection(from: departureButton, defaultTitle: "Место отправления"),
            arrivalPlace: normalizedSelection(from: arrivalButton, defaultTitle: "Место прибытия")
        )
        
        onApply?(data)
        collapse(animated: true)
    }
    
    @objc
    private func resetTapped() {
        resetFields()
        onReset?()
    }
    
    // MARK: - State
    private func updateExpandedState(animated: Bool) {
        let changes = {
            self.contentContainer.alpha = self.isExpanded ? 1 : 0
            
            if self.isExpanded {
                self.contentHeightConstraint?.constant = self.calculatedContentHeight()
            } else {
                self.contentHeightConstraint?.constant = 0
            }
            
            self.updateTopButtonAppearance()
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: Constants.animationDuration) {
                changes()
            }
        } else {
            changes()
        }
        
        onToggle?(isExpanded)
    }
    
    private func updateTopButtonAppearance() {
        if isExpanded {
            topFilterButton.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
        } else {
            topFilterButton.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        }
    }
    
    private func calculatedContentHeight() -> CGFloat {
        contentContainer.layoutIfNeeded()
        contentStack.layoutIfNeeded()
        
        let targetSize = CGSize(width: bounds.width - Constants.sideInset * 2, height: UIView.layoutFittingCompressedSize.height)
        let stackHeight = contentStack.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        
        return stackHeight + Constants.contentTopInset + Constants.bottomInset
    }
    
    private func resetFields() {
        dateInputView.selectedDate = nil
        timeFromInputView.selectedTime = nil
        timeToInputView.selectedTime = nil
        
        dateInputView.textField.text = nil
        timeFromInputView.textField.text = nil
        timeToInputView.textField.text = nil
        
        departureButton.titleLabel.text = "Место отправления"
        departureButton.choosenSection = "Нет данных"
        
        arrivalButton.titleLabel.text = "Место прибытия"
        arrivalButton.choosenSection = "Нет данных"
    }
    
    private func normalizedSelection(from button: ChooseFilterButton, defaultTitle: String) -> String? {
        let selected = button.choosenSection.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentTitle = button.titleLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if selected.isEmpty || selected == "Нет данных" {
            if currentTitle == defaultTitle {
                return nil
            }
            return currentTitle.isEmpty ? nil : currentTitle
        }
        
        return selected
    }
    
    // MARK: - Helpers
    private func makeHorizontalStack(spacing: CGFloat) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = spacing
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }
}
