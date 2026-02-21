import UIKit

final class TwoColumnRowView: UIView {

    //MARK: Enum for cell
    enum CellContent {
        case text(String)
        case icon(String)
    }

    //MARK: Constants
    private enum Constants {
        
        static let separatorWidth: CGFloat = 2
        static let separatorColor: UIColor = .black
        static let bg: UIColor = UIColor(white: 0.70, alpha: 1)
        static let textColor: UIColor = .black
        
        static let cellWidth: CGFloat = 200
    }
    
    //MARK: Fields
    private let hStack = UIStackView()
    private let leftCell = CellView()
    private let rightCell = CellView()
    private let vSeparator = UIView()

    init(isHeader: Bool = false) {
        super.init(frame: .zero)
        backgroundColor = Constants.bg
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.alignment = .fill
        hStack.spacing = 0

        vSeparator.backgroundColor = Constants.separatorColor

        addSubview(hStack)
        hStack.addArrangedSubview(leftCell)
        hStack.addArrangedSubview(vSeparator)
        hStack.addArrangedSubview(rightCell)

        hStack.pinTop(to: topAnchor)
        hStack.pinHorizontal(to: self)
        hStack.pinBottom(to: bottomAnchor)
        
        vSeparator.setWidth(Constants.separatorWidth)
        leftCell.widthAnchor.constraint(equalTo: rightCell.widthAnchor).isActive = true
    }

    func set(left: CellContent, right: CellContent, isHeader: Bool) {
        leftCell.set(content: left, isHeader: isHeader, alignment: .center)
        rightCell.set(content: right, isHeader: isHeader, alignment: .center)
    }
}

