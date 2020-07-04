//
//  SubjectCell.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 01.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit

class SubjectCell: UITableViewCell {

    public static let id = "SubjectCell"
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var rateCircle: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        rateCircle.layer.cornerRadius = rateCircle.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(subject: DataManager.subject) {
        subjectLabel.text = subject.getNormalTitle()
        if subject.maxRate == "0" {
            rateLabel.text = "\u{2014}"
        } else {
            rateLabel.text = subject.rate
        }
        
        let circleConfig = Utilities.getCircleConfig(subject: subject)
        rateCircle.backgroundColor = circleConfig.circleColor
        rateLabel.textColor = circleConfig.labelColor
    }
}
