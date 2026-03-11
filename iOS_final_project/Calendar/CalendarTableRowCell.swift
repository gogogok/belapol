//
//  CalendarTableRowCell.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 11.03.26.
//

import UIKit

final class CalendarTableRowCell: UITableViewCell {
    
    static let reuseIdentifier = "CalendarTableRowCell"
    
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear
        
        contentView.addSubview(hStack)
        hStack.pinTop(to: contentView.topAnchor, 8)
        hStack.pinBottom(to: contentView.bottomAnchor, 8)
        hStack.pinLeft(to: contentView.leadingAnchor, 8)
        hStack.pinRight(to: contentView.trailingAnchor, 8)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hStack.arrangedSubviews.forEach {
            hStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    func configure(columns: [String]) {
        hStack.arrangedSubviews.forEach {
            hStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        for text in columns {
            let label = UILabel()
            label.font = .systemFont(ofSize: 15)
            label.textColor = .label
            label.textAlignment = .center
            label.numberOfLines = 0
            label.text = text.isEmpty ? "—" : text
            
            let container = UIView()
            container.layer.cornerRadius = 10
            container.backgroundColor = UIColor.secondarySystemBackground
            
            container.addSubview(label)
            label.pinTop(to: container.topAnchor, 10)
            label.pinBottom(to: container.bottomAnchor, 10)
            label.pinLeft(to: container.leadingAnchor, 8)
            label.pinRight(to: container.trailingAnchor, 8)
            
            hStack.addArrangedSubview(container)
        }
    }
}
