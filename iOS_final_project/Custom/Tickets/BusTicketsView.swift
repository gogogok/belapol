//
//  BaseTicketsView.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 25.02.26.
//

import UIKit

final class BusTicketsView: UIView {

    //MARK: - Constants
    private enum Constants {
        static let fontSize: CGFloat = 20
        static let fontName: String = "InriaSans-Bold"
    }
    
    // MARK: - UI
    private let bgImageView: UIImageView = {
        let imView = UIImageView()
        imView.contentMode = .scaleAspectFill
        imView.clipsToBounds = true
        imView.alpha = 0.4
        imView.layer.borderColor = UIColor.white.cgColor
        imView.layer.cornerRadius = 15
        imView.layer.borderWidth = 2
        return imView
    }()

    private let titleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 15, weight: .heavy)
        title.textColor = .white
        title.numberOfLines = 2
        title.setContentCompressionResistancePriority(.required, for: .vertical)
        title.setWidth(200)
        return title
    }()

    private let fromLabel: UILabel = {
        let from = UILabel()
        from.font = .systemFont(ofSize: 12)
        from.textColor = .white
        from.setWidth(300)
        return from
    }()
    
    private let toLabel: UILabel = {
        let to = UILabel()
        to.font = .systemFont(ofSize: 11)
        to.textColor = .white
        to.setWidth(300)
        return to
    }()

    private let pointLabel: UILabel = {
        let point = UILabel()
        point.font = .italicSystemFont(ofSize: 10)
        point.textColor = .white
        return point
    }()
    
    private let dateLabel: UILabel = {
        let date = UILabel()
        date.font =  UIFont(name: Constants.fontName, size: Constants.fontSize - 2)
        date.textAlignment = .right
        date.textColor = .white
        date.numberOfLines = 3
        date.setWidth(100)
        return date
    }()
    
    private let timeLabel: UILabel = {
        let date = UILabel()
        date.font =  UIFont(name: Constants.fontName, size: Constants.fontSize)
        date.textAlignment = .right
        date.textColor = .white
        date.numberOfLines = 3
        date.setWidth(90)
        return date
    }()
    
//    private let gradeLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 11, weight: .bold)
//        label.textColor = .white
//        label.numberOfLines = 1
//        label.layer.cornerRadius = 12
//        label.setWidth(25)
//        label.setHeight(25)
//        label.textAlignment = .center
//        label.backgroundColor = .black
//        label.clipsToBounds = true
//        return label
//    }()

    // MARK: - Lyfecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Configure
    private func configureUI() {
        layer.cornerRadius = 15
        clipsToBounds = true

        addSubview(bgImageView)
        addSubview(titleLabel)
        addSubview(fromLabel)
        addSubview(toLabel)
        addSubview(pointLabel)
        addSubview(dateLabel)
        //addSubview(gradeLabel)
        addSubview(timeLabel)

        bgImageView.pin(to: self)
        
        titleLabel.pinTop(to: topAnchor, 10)
        titleLabel.pinLeft(to: leadingAnchor, 10)
        
//        gradeLabel.pinLeft(to: titleLabel.trailingAnchor, 10)
//        gradeLabel.pinVertical(to: titleLabel)
    
        fromLabel.pinTop(to: titleLabel.bottomAnchor, 10)
        toLabel.pinTop(to: fromLabel.bottomAnchor, 2)
        fromLabel.pinLeft(to: leadingAnchor, 10)
        toLabel.pinLeft(to: leadingAnchor, 10)
        
        dateLabel.pinTop(to: topAnchor, 10)
        dateLabel.pinRight(to: trailingAnchor, 10)
        
        timeLabel.pinTop(to: dateLabel.bottomAnchor, 5)
        timeLabel.pinRight(to: trailingAnchor, 10)
        
        pointLabel.pinBottom(to: bottomAnchor, 10)
        pointLabel.pinHorizontal(to: self, 10)
        
        setHeight(125)
    }

    func configure (title: String, stationFrom: String, stationTo: String, point: String, date: String, time: String, image: UIImage, grade: String) {
        titleLabel.text = title
        fromLabel.text = stationFrom
        toLabel.text = stationTo
        pointLabel.text = point
        dateLabel.text = date
        timeLabel.text = time
        bgImageView.image = image
        //gradeLabel.text = grade
        //updateGradeColor()
    }
    
//    private func updateGradeColor() {
//        guard let text = gradeLabel.text,
//              let value = Double(text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "."))
//        else {
//            gradeLabel.backgroundColor = .black
//            return
//        }
//        
//        switch value {
//        case 1.0...3.0:
//            gradeLabel.backgroundColor = .systemRed
//        case 4.0...7.0:
//            gradeLabel.backgroundColor = .systemOrange
//        case 8.0...10.0:
//            gradeLabel.backgroundColor = .systemGreen
//        default:
//            gradeLabel.backgroundColor = .white
//        }
//    }
}

