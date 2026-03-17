//
//  BasicButtonView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 18.02.26.
//

import UIKit

final class BasicButtonView : UIButton {
    
    //MARK: - Constants
    enum Constants{
        
        static let buttonColor : UIColor = UIColor(hex: "#DB8C42") ?? .orange
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
        
        setTitle(label, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        
        titleLabel?.textAlignment = .center
        (self as UIView).setWidth(width)
        (self as UIView).setHeight(height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
