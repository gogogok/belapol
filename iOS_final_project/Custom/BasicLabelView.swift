//
//  BasicLabelView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 18.02.26.
//

import UIKit

final class BasicLabelView : UILabel {
    
    //MARK: - Constants
    enum Constants{
        
        static let buttonColor : UIColor = UIColor(hex: "#DB8C42") ?? .orange
        static let cornerRadius: CGFloat = 10
        
        static let fontSize: CGFloat = 15
        static let fontName: String = "InriaSans-Bold"
    }
    
    var textInsets : UIEdgeInsets?
    
    
    //MARK: - LifeCycle
    init (label: String, width: CGFloat, height: CGFloat, left: CGFloat = 12, right: CGFloat = 20) {
        super.init(frame: .zero)
        textInsets = UIEdgeInsets(top: 12, left: left, bottom: 12, right: right)
        backgroundColor = Constants.buttonColor
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
        numberOfLines = 0
        
        text = label
        font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        
        textAlignment = .center
        (self as UIView).setWidth(width)
        (self as UIView).setHeight(height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func drawText(in rect: CGRect) {
        guard let textInsets else {return}
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        guard let textInsets else { return CGSize(width: size.width, height: size.height)}
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
    
}
