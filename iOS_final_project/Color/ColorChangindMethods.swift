//
//  colorChangindMethods.swift
//  dszhdanokPW2
//
//  Created by Дарья Жданок on 21.09.25.
//

import UIKit

//MARK: - Constants

private enum Constants {
    static let alphaFullValue: CGFloat = 1.0
}

public final class ColorChangindMethods {
    
    //MARK: - Color Changing Methods
    
    public static func getHEXColor(hex: String) -> UIColor {
        var result = UIColor()
        if let color = UIColor(hex: hex) {
            result = color
        }
        return result
    }
    
    
    public static func getRandomColor() -> UIColor {
        let color = UIColor(
            displayP3Red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: Constants.alphaFullValue
        )
        return color
    }
}
