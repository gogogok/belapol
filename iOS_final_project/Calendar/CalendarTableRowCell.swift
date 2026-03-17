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
    
    private var labels: [UILabel] = []
    private let columnsCount = 4
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupColumns()
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
    
    private func setupColumns() {
        for _ in 0..<columnsCount {
            let label = UILabel()
            label.font = .systemFont(ofSize: 15)
            label.textColor = .label
            label.textAlignment = .center
            label.numberOfLines = 0
            
            let container = UIView()
            container.layer.cornerRadius = 10
            container.backgroundColor = .secondarySystemBackground
            
            container.addSubview(label)
            label.pinTop(to: container.topAnchor, 10)
            label.pinBottom(to: container.bottomAnchor, 10)
            label.pinLeft(to: container.leadingAnchor, 8)
            label.pinRight(to: container.trailingAnchor, 8)
            
            hStack.addArrangedSubview(container)
            labels.append(label)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for label in labels {
            label.text = nil
        }
    }
    
    func configure(columns: [String]) {
        for index in 0..<labels.count {
            if index < columns.count {
                let text = columns[index]
                labels[index].text = text.isEmpty ? "—" : text
            } else {
                labels[index].text = "—"
            }
        }
    }
}
