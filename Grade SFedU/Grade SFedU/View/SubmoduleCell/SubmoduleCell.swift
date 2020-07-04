//
//  SubmoduleCell.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 02.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit

class SubmoduleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var rightElements: UIStackView!
    static let id = "SubmoduleCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(title: String, rate: String, date: String) {
        if rate.isEmpty && date.isEmpty {
            rightElements.isHidden = true
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            titleLabel.textAlignment = .center
        } else {
            rightElements.isHidden = false
            titleLabel.textAlignment = .left
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
        
        
        titleLabel.text = title
        rateLabel.text = rate
        dateLabel.text = String(date.prefix(5))
    }
}
