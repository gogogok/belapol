//
//  CatBackButton.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 18.02.26.
//

import UIKit

final class CatBackButton : UIButton {
    
    //MARK: - Constants
    
    enum Constants{
        static let backGroundImageName: String = "back_button"
    }
    
    //MARK: - LifeCycle
    init () {
        super.init(frame: .zero)
        self.setImage(UIImage(named: Constants.backGroundImageName), for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
