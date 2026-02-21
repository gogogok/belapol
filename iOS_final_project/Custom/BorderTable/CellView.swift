//
//  CellView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 21.02.26.
//
import UIKit

final class CellView: UIView {

    private enum Constants {
        static let textColor: UIColor = .white
        static let iconSize: CGFloat = 45

        static let headerFont = UIFont(name: "GillSans-Bold", size: 17)!
        static let valueFont = UIFont(name: "GillSans-Bold", size: 16)!
        
        static let stokeWidth: CGFloat = 5
        static let stokeColore: UIColor = .black
        
    }
    
    let label = UILabel()
    let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
       
        backgroundColor = .clear
        label.numberOfLines = 1
        label.textAlignment = .center

        iconView.tintColor = .black
        iconView.contentMode = .scaleAspectFit

        addSubview(label)
        addSubview(iconView)
        
        iconView.setHeight(Constants.iconSize)
        iconView.setWidth(Constants.iconSize)
        iconView.pinCenter(to: self)
        
        label.pinCenter(to: self)
    }

    func set(content: TwoColumnRowView.CellContent,
             isHeader: Bool,
             alignment: NSTextAlignment) {
        
        label.textAlignment = alignment
        
        switch content {
            
        case .text(let text):
            iconView.isHidden = true
            label.isHidden = false
            
            let font = isHeader ? Constants.headerFont : Constants.valueFont
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: Constants.textColor,
                .strokeColor: Constants.stokeColore,
                .strokeWidth: -Constants.stokeWidth
            ]
            
            label.attributedText = NSAttributedString(string: text, attributes: attributes)
            
        case .icon(let systemName):
            label.isHidden = true
            iconView.isHidden = false
            iconView.image = UIImage(systemName: systemName)
            
        }
    }
}
