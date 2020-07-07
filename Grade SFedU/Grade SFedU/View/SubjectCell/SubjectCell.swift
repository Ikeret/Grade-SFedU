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
        subjectLabel.text = subject.getTitle()
        if subject.maxRate == "0" {
            rateLabel.text = "\u{2014}"
        } else {
            rateLabel.text = subject.rate
        }
        
        let circleConfig = DataManager.getCircleConfig(subject: subject)
        rateCircle.backgroundColor = circleConfig.circleColor
        rateLabel.textColor = circleConfig.labelColor
        
        if subject.isHidden() {
            contentView.alpha = 0.5
        } else {
            contentView.alpha = 1.0
        }
    }
}
