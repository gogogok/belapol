//
//  CalendarTable.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 21.02.26.
//

import UIKit

import UIKit

final class CalendarTable: UIView {
    
    typealias Model = MainTableModel
    
    enum Constants {
        static let cornerRadius: CGFloat = 28
        static let sideInset: CGFloat = 20
        static let topInset: CGFloat = 20
        static let bottomInset: CGFloat = 20
        
        static let sheetHeight: CGFloat = 540
        
        static let shareButtonSize: CGFloat = 50
        static let closeButtonTrailing: CGFloat = -60
        
        static let titleFontSize: CGFloat = 15
        static let subtitleFontSize: CGFloat = 14
        
        static let titleTopSpacing: CGFloat = 30
        static let tableTopSpacing: CGFloat = 10
        
        static let closeButtonImageName: String = "back_button"
        
        static let separatorColor: UIColor = UIColor(white: 0.88, alpha: 1)
        static let headerBackgroundColor: UIColor = UIColor(hex: "#F3F3F3") ?? .secondarySystemBackground
        static let sheetBackgroundColor: UIColor = .systemBackground
        
        static let rowMinHeight: CGFloat = 44
        static let emptyText: String = "Нет данных"
    }
    
    var onClose: (() -> Void)?
    var onShareTap: ((UIActivityViewController) -> Void)?
    
    private let data: Model.ArchiveQueueTableData
    
    private let dimView: UIControl = {
        let view = UIControl()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        view.alpha = 0
        return view
    }()
    
    private let sheet = UIView()
    private let shareButton = UIButton(type: .system)
    private let closePawButton = CloseButton(backImage: UIImage(named: Constants.closeButtonImageName))
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.subtitleFontSize)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var sheetBottomConstraint: NSLayoutConstraint?
    
    private var headerRow: [String]? {
        guard let first = data.rows.first?.columns, data.rows.count > 1 else { return nil }
        return first
    }
    
    private var bodyRows: [Model.ArchiveQueueRow] {
        guard !data.rows.isEmpty else { return [] }
        if headerRow != nil {
            return Array(data.rows.dropFirst())
        }
        return data.rows
    }
    
    init(data: Model.ArchiveQueueTableData) {
        self.data = data
        super.init(frame: .zero)
        setupUI()
        setupActions()
        setupTableView()
        fillContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(dimView)
        dimView.pin(to: self)
        
        addSubview(sheet)
        sheet.backgroundColor = Constants.sheetBackgroundColor
        sheet.layer.cornerRadius = Constants.cornerRadius
        sheet.clipsToBounds = true
        
        sheet.pinLeft(to: self, Constants.sideInset)
        sheet.pinRight(to: self, Constants.sideInset)
        sheet.setHeight(Constants.sheetHeight)
        
        sheetBottomConstraint = sheet.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: Constants.sheetHeight
        )
        sheetBottomConstraint?.isActive = true
        
        setupTopBar()
        setupTitleBlock()
        setupDataTable()
    }
    
    private func setupTopBar() {
        shareButton.setWidth(Constants.shareButtonSize)
        shareButton.setHeight(Constants.shareButtonSize)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .black
        
        sheet.addSubview(shareButton)
        shareButton.pinTop(to: sheet, Constants.topInset)
        shareButton.pinLeft(to: sheet, Constants.sideInset)
        
        sheet.addSubview(closePawButton)
        closePawButton.pinCenterY(to: shareButton, 4)
        closePawButton.pinRight(to: sheet.trailingAnchor, Constants.closeButtonTrailing)
    }
    
    private func setupTitleBlock() {
        sheet.addSubview(titleLabel)
        titleLabel.pinTop(to: shareButton.bottomAnchor, Constants.titleTopSpacing)
        titleLabel.pinLeft(to: sheet.leadingAnchor, 20)
        titleLabel.pinRight(to: sheet.trailingAnchor, 20)
        
        sheet.addSubview(subtitleLabel)
        subtitleLabel.pinTop(to: titleLabel.bottomAnchor, 6)
        subtitleLabel.pinLeft(to: sheet.leadingAnchor, 20)
        subtitleLabel.pinRight(to: sheet.trailingAnchor, 20)
    }
    
    private func setupDataTable() {
        sheet.addSubview(tableView)
        tableView.pinTop(to: subtitleLabel.bottomAnchor, Constants.tableTopSpacing)
        tableView.pinLeft(to: sheet.leadingAnchor, 16)
        tableView.pinRight(to: sheet.trailingAnchor, 16)
        tableView.pinBottom(to: sheet.bottomAnchor, Constants.bottomInset)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorColor = Constants.separatorColor
        tableView.showsVerticalScrollIndicator = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        
        tableView.register(CalendarTableRowCell.self, forCellReuseIdentifier: CalendarTableRowCell.reuseIdentifier)
        tableView.register(CalendarTableHeaderView.self, forHeaderFooterViewReuseIdentifier: CalendarTableHeaderView.reuseIdentifier)
        
        tableView.tableFooterView = UIView()
    }
    
    private func fillContent() {
        titleLabel.text = data.title
        
        if bodyRows.isEmpty {
            subtitleLabel.text = Constants.emptyText
        } else {
            subtitleLabel.text = "Строк: \(bodyRows.count)"
        }
    }
    
    private func setupActions() {
        dimView.addTarget(self, action: #selector(didTapDim), for: .touchUpInside)
        closePawButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    @objc private func didTapDim() {
        hide()
    }
    
    @objc private func didTapClose() {
        hide()
    }
    
    @objc private func shareButtonTapped() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let jsonData = try encoder.encode(data)
            
            let fileName = makeFileName()
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            try jsonData.write(to: fileURL, options: .atomic)
            
            let activityVC = UIActivityViewController(
                activityItems: [fileURL],
                applicationActivities: nil
            )
            
            onShareTap?(activityVC)
        } catch {
            print("Ошибка шаринга JSON:", error)
        }
    }
    
    
    func show(in parent: UIView) {
        parent.addSubview(self)
        pin(to: parent, 0)
        parent.layoutIfNeeded()
        
        sheetBottomConstraint?.constant = -8
        
        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.dimView.alpha = 1
            parent.layoutIfNeeded()
        }
    }
    
    func hide() {
        guard let parent = superview else { return }
        
        sheetBottomConstraint?.constant = Constants.sheetHeight
        
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn]) {
            self.dimView.alpha = 0
            parent.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
            self.onClose?()
        }
    }
    
    private func makeFileName() -> String {
        let rawTitle = data.title.isEmpty ? "archive_queue" : data.title
        
        let safeTitle = rawTitle
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "'", with: "")
        
        return "\(safeTitle).json"
    }
}

// MARK: - UITableViewDataSource
extension CalendarTable: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return bodyRows.isEmpty ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bodyRows.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CalendarTableRowCell.reuseIdentifier,
                for: indexPath
            ) as? CalendarTableRowCell
        else {
            return UITableViewCell()
        }
        
        let row = bodyRows[indexPath.row]
        cell.configure(columns: row.columns)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CalendarTable: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerRow else { return nil }
        
        guard
            let view = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: CalendarTableHeaderView.reuseIdentifier
            ) as? CalendarTableHeaderView
        else {
            return nil
        }
        
        view.configure(columns: headerRow)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerRow == nil ? 0.01 : 50
    }
}
