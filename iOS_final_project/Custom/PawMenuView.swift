//
//  PawButton.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 21.02.26.
//

import UIKit

final class PawMenuView: UIView {

    enum Constants {
        static let pawSize: CGFloat = 64
        static let menuWidth: CGFloat = 280

        static let menuCorner: CGFloat = 24
        static let buttonHeight: CGFloat = 30
        static let buttonSpacing: CGFloat = 12

        static let stackTop : CGFloat = 10
        
        static let topInset: CGFloat = 20
        static let innerLeftRight: CGFloat = 15
        
        static let backGroundImageName: String = "paw_button"
    }

    //MARK: - callbacks
    var onOpenStateChange: ((Bool) -> Void)?
    
    var onTapQueue: (() -> Void)?
    var onTapTicket: (() -> Void)?
    var onTapNews: (() -> Void)?
    var onTapContacts: (() -> Void)?
    var onTapCollection: (() -> Void)?

    private var isOpen = false

    private let pawButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: Constants.backGroundImageName), for: .normal)
        b.layer.cornerRadius = CGFloat(Constants.pawSize / 2)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    private let menuView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.22, alpha: 1.0) 
        v.layer.cornerRadius = Constants.menuCorner
        v.clipsToBounds = true
        v.alpha = 0
        return v
    }()

    private let stack = UIStackView()

    private var menuWidthConstraint: NSLayoutConstraint?
    private var menuHeightConstraint: NSLayoutConstraint?

    private let items: [UIButton] = [
        PawMenuView.makeItem(title: "Очередь на КПП"),
        PawMenuView.makeItem(title: "Выбрать билет"),
        PawMenuView.makeItem(title: "Новости"),
        PawMenuView.makeItem(title: "Контакты границы"),
        PawMenuView.makeItem(title: "Коллекция билетов")
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
        setClosedState(animated: false)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
        setClosedState(animated: false)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if !isOpen { return super.point(inside: point, with: event) }

        let p = convert(point, to: menuView)
        return menuView.point(inside: p, with: event)
    }

    private func setupUI() {
        // маленькая кнопка
        addSubview(pawButton)
        pawButton.setWidth(Constants.pawSize)
        pawButton.setHeight(Constants.pawSize)
        pawButton.pinTop(to: self, 0)
        pawButton.pinLeft(to: self, 0)

        // меню-контейнер
        addSubview(menuView)
        menuView.pinTop(to: self, 0)
        menuView.pinLeft(to: self, 0)

        menuWidthConstraint = menuView.setWidth(Constants.pawSize)
        menuHeightConstraint = menuView.setHeight(Constants.pawSize)

        // stack
        stack.axis = .vertical
        stack.spacing = Constants.buttonSpacing
        stack.alignment = .fill
        stack.distribution = .fillEqually

        menuView.addSubview(stack)
        stack.pinTop(to: pawButton.bottomAnchor, Constants.stackTop)
        stack.pinLeft(to: menuView, Constants.innerLeftRight)
        stack.pinRight(to: menuView, Constants.innerLeftRight)

        items.forEach {
            $0.setHeight(Constants.buttonHeight)
            stack.addArrangedSubview($0)
        }
        
        bringSubviewToFront(pawButton)
    }

    private func setupActions() {
        pawButton.addTarget(self, action: #selector(toggle), for: .touchUpInside)

        items[0].addTarget(self, action: #selector(tapQueue), for: .touchUpInside)
        items[1].addTarget(self, action: #selector(tapTicket), for: .touchUpInside)
        items[2].addTarget(self, action: #selector(tapNews), for: .touchUpInside)
        items[3].addTarget(self, action: #selector(tapContacts), for: .touchUpInside)
        items[4].addTarget(self, action: #selector(tapCollection), for: .touchUpInside)
    }

    @objc func toggle() {
        isOpen ? close() : open()
    }

    func open() {
        guard let superview else { return }
        onOpenStateChange?(true)
        isOpen = true

        // показываем контейнер и увеличиваем его
        menuView.alpha = 1

        menuWidthConstraint?.constant = Constants.menuWidth
        menuHeightConstraint?.constant = 5 * (Constants.buttonHeight + Constants.buttonSpacing) + Constants.pawSize + Constants.topInset

        // “наплывание” кнопок: сначала спрятать
        items.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: -10)
        }

        superview.layoutIfNeeded()

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            superview.layoutIfNeeded()
        } completion: { _ in
            // наплывание по очереди
            for (i, btn) in self.items.enumerated() {
                UIView.animate(withDuration: 0.22, delay: Double(i) * 0.04, options: [.curveEaseOut]) {
                    btn.alpha = 1
                    btn.transform = .identity
                }
            }
        }
    }

    func close() {
        guard let superview else { return }
        onOpenStateChange?(false)
        isOpen = false

        // прячем пункты
        UIView.animate(withDuration: 0.12) {
            self.items.forEach { $0.alpha = 0 }
        }

        // уменьшаем контейнер обратно в кнопку
        menuWidthConstraint?.constant = Constants.pawSize
        menuHeightConstraint?.constant = Constants.pawSize

        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn]) {
            superview.layoutIfNeeded()
        } completion: { _ in
            self.menuView.alpha = 0
        }
    }

    private func setClosedState(animated: Bool) {
        isOpen = false
        menuView.alpha = 0
        items.forEach { $0.alpha = 0 }
    }

    // MARK: - Item style
    private static func makeItem(title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        b.backgroundColor = UIColor(red: 0.86, green: 0.56, blue: 0.23, alpha: 1)
        b.layer.cornerRadius = 15
        b.clipsToBounds = true
        return b
    }

    // MARK: - taps
    @objc private func tapQueue() { onTapQueue?() }
    @objc private func tapTicket() { onTapTicket?() }
    @objc private func tapNews() { onTapNews?() }
    @objc private func tapContacts() { onTapContacts?() }
    @objc private func tapCollection() { onTapCollection?() }

}
