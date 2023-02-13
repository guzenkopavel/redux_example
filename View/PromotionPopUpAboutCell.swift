//
// Created by Pavel Guzenko on 31.01.2023.
//

import Foundation
import UIKit

class PromotionPopUpAboutCell: UITableViewCell {
    var text: String? {
        didSet {
            titleLabel.text = text
        }
    }

    required init?(coder: NSCoder) {
        fatalError("note implemented")
    }

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-18)
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Color.goldenRed
        label.font = .systemFont(ofSize: 18)
        return label
    }()
}