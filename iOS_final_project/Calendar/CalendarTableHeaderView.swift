//
//  CalendarTableHeaderView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 11.03.26.
//

import UIKit

final class CalendarTableHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "CalendarTableHeaderView"
    
    private let bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F3F3F3") ?? .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(bgView)
        bgView.pinTop(to: contentView.topAnchor, 0)
        bgView.pinBottom(to: contentView.bottomAnchor, 6)
        bgView.pinLeft(to: contentView.leadingAnchor, 0)
        bgView.pinRight(to: contentView.trailingAnchor, 0)
        
        bgView.addSubview(hStack)
        hStack.pinTop(to: bgView.topAnchor, 8)
        hStack.pinBottom(to: bgView.bottomAnchor, 8)
        hStack.pinLeft(to: bgView.leadingAnchor, 8)
        hStack.pinRight(to: bgView.trailingAnchor, 8)
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
            label.font = .boldSystemFont(ofSize: 12)
            label.textColor = .label
            label.textAlignment = .center
            label.numberOfLines = 0
            label.text = text
            
            hStack.addArrangedSubview(label)
        }
    }
}
