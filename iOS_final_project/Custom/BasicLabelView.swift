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
        
        static let buttonColor : UIColor = UIColor(hex: "#DB8C42")!
        static let cornerRadius: CGFloat = 10
        
        static let fontSize: CGFloat = 15
        static let fontName: String = "InriaSans-Bold"
    }
    
    
    //MARK: - LifeCycle
    init (label: String, width: CGFloat, height: CGFloat) {
        super.init(frame: .zero)
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
    
    var textInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 20)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
    
}
