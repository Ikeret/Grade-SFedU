//
//  TodaySubjectCell.swift
//  Grade SFedU TE
//
//  Created by Сергей Коршунов on 06.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit

class TodaySubjectCell: UITableViewCell {
    static let id = "TodaySubjectCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
