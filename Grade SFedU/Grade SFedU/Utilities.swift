//
//  Utilities.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 01.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit

class Utilities {
    static let markA = UIColor(named: "markA")!
    static let markB = UIColor(named: "markB")!
    static let markC = UIColor(named: "markC")!
    static let markD = UIColor(named: "markD")!
    
    public static func getCircleConfig(subject: DataManager.subject) -> (circleColor: UIColor, labelColor: UIColor) {
        guard subject.maxRate != "0" else {
            return (.systemGray, .white)
        }
        
        let percent = Double(subject.rate)! / Double(subject.maxRate)!
        
        if subject.type == "Зачет" {
            return percent >= 0.60 ? (markA, .white) : (markD, .white)
        }
        
        if percent < 0.38 {
            return (markD, .white)
        } else if percent >= 0.71 && percent < 0.85 {
            return (markB, .white)
        } else if percent >= 0.85 {
            return (markA, .white)
        } else {
            return (markC, .black)
        }
    }
}
