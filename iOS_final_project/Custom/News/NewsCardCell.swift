//
//  NewsCardCell.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 26.02.26.
//

import UIKit

final class NewsCardCell: UICollectionViewCell {
    static let reuseId = "NewsCardCell"

    private let card = NewsCardView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(card)
        card.pin(to: contentView)
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, date: String, subtitle: String, image: UIImage) {
        card.configure(title: title, dateText: date, subtitle: subtitle, image: image)
    }
}
