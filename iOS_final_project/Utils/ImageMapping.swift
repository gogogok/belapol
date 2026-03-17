//
//  ImageMapping.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 13.03.26.
//
import UIKit

public class ImageMapping {
    public static func image(bus: String) -> UIImage? {
        
        let lower = bus.lowercased()
        
        let map: [String: String] = [
            "ecolines": "ecolines_bus",
            "эколайнс": "ecolines_bus",
            "минсктранс": "minsk_trans_bus",
            "рич бай": "rich_bus",
            "rich-bus": "rich_bus",
            "визиттур": "visit_tour_bus",
            "пкс гданьск": "pks_gdansk_bus",
            "интеркарс": "intercars_bus",
            "intercars": "intercars_bus"
        ]
        
        for (keyword, imageName) in map {
            if lower.contains(keyword) {
                return UIImage(named: imageName) ?? nil
            }
        }
        
        return UIImage(named: "default_bus") ?? nil
    }

}
