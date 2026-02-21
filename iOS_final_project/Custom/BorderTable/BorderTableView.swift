//
//  BorderTableView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 21.02.26.
//

import UIKit

final class BorderTableView: UIView {
    
    // MARK: - Row
    struct Row {
        let iconSystemName: String
        let valueText: String
    }
    
    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: CGFloat = 36
        static let borderWidth: CGFloat = 3
        static let separatorWidth: CGFloat = 2
        static let rowHeight: CGFloat = 60
        static let headerHeight: CGFloat = 30
        
        static let bg: UIColor = UIColor(white: 0.70, alpha: 1)
        static let border: UIColor = .white
        static let separator: UIColor = .black
        
        static let textColor: UIColor = .white
        static let shadowOpacity: Float = 0.25
        static let shadowRadius: CGFloat = 12
        static let shadowOffset = CGSize(width: 0, height: 6)
        
        static let separatorHeihgt: CGFloat = 2
    }
    
    // MARK: - Fields
    let outerBorder = UIView()
    let container = UIView()
    
    let rootStack = UIStackView()
    let headerRow : TwoColumnRowView = TwoColumnRowView(isHeader: true)
    
    let row1 : TwoColumnRowView = TwoColumnRowView()
    let row2 : TwoColumnRowView = TwoColumnRowView()
    let row3 : TwoColumnRowView = TwoColumnRowView()
    
    // MARK: - Lyfecyrcle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureElemebts()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(headerLeft: String, headerRight: String, rows: [Row]) {
        headerRow.set(left: .text(headerLeft), right: .text(headerRight), isHeader: true)
        
        let views = [row1, row2, row3]
        for (i, view) in views.enumerated() {
            if i < rows.count {
                view.set(left: .icon(rows[i].iconSystemName), right: .text(rows[i].valueText), isHeader: false)
            }
        }
    }
    
    // MARK: - Configure
    private func configureElemebts() {
        backgroundColor = .clear
        
        outerBorder.backgroundColor = Constants.border
        outerBorder.layer.cornerRadius = Constants.cornerRadius
        outerBorder.layer.masksToBounds = true
        
        container.backgroundColor = Constants.bg
        container.layer.cornerRadius = Constants.cornerRadius - Constants.borderWidth
        container.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowRadius = Constants.shadowRadius
        layer.shadowOffset = Constants.shadowOffset
        
        rootStack.axis = .vertical
        rootStack.distribution = .fill
        rootStack.alignment = .fill
        rootStack.spacing = 0
        
        rootStack.addArrangedSubview(headerRow)
        rootStack.addArrangedSubview(makeHSeparator())
        rootStack.addArrangedSubview(row1)
        rootStack.addArrangedSubview(makeHSeparator())
        rootStack.addArrangedSubview(row2)
        rootStack.addArrangedSubview(makeHSeparator())
        
        rootStack.addArrangedSubview(row3)
        
        addSubview(outerBorder)
        outerBorder.addSubview(container)
        container.addSubview(rootStack)
        
        headerRow.setHeight(Constants.headerHeight)
        row1.setHeight(Constants.rowHeight)
        row2.setHeight(Constants.rowHeight)
        row3.setHeight(Constants.rowHeight)
    }
    
    private func configureLayout() {
        
        outerBorder.pin(to: self)
        container.pin(to: outerBorder, Constants.borderWidth)
        rootStack.pin(to: container)
    }
    
    private func makeHSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = Constants.separator
        v.setWidth(Constants.separatorWidth)
        v.setHeight(Constants.separatorHeihgt)
        return v
    }
}
