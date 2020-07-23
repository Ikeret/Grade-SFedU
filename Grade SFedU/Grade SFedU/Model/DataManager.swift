//
//  DataManager.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 04.05.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit

class DataManager {
    
    static let sharedDefaults = UserDefaults(suiteName: "group.sharingToTodayView")!
    
    static var expireCookie: Double = 0
    
    static func isExpire() -> Bool {
        return Date().timeIntervalSince1970 > expireCookie
    }
    
    struct subject {
        var title: String
        var link: String
        var rate: String
        var maxRate: String
        var type: String
        
        func getTitle() -> String {
            if showNormalTitle {
                return sharedDefaults.string(forKey: "rename \(title)") ?? title
            } else {
                return title
            }
        }
        
        func isHidden() -> Bool {
            return sharedDefaults.bool(forKey: "hidden \(link)")
        }
    }
    
    static var subjects = [subject]()
    
    static func saveTotalRating() {
        if !subjects.isEmpty && (currentSemestr == semestrs.first?.title) {
            let totalRating = subjects.reduce(0, {$0 + (Int($1.rate) ?? 0)})
            sharedDefaults.set(totalRating, forKey: "totalRating")
        }
    }
    
    static func compareTotalRating() -> Bool {
        if !subjects.isEmpty && (currentSemestr == semestrs.first?.title) {
            let totalRating = subjects.reduce(0, {$0 + (Int($1.rate) ?? 0)})
            return totalRating != sharedDefaults.integer(forKey: "totalRating")
        }
        return false
    }
    
    static var currentSemestr = "Дисциплины"
    
    struct semestr {
        var title: String
        var id: String
    }
    
    static var semestrs = [semestr]()
    
    struct module {
        var title: String
        var submoles: [submodule]
    }
    
    struct submodule {
        var title: String
        var rate: String
        var date: String
    }
    
    static func getUser() -> (login: String, password: String) {
        let login = sharedDefaults.string(forKey: "login") ?? ""
        let password = sharedDefaults.string(forKey: "password") ?? ""
        
        return (login, password)
    }
    
    static func setUser(login: String?, password: String?) {
        sharedDefaults.set(login, forKey: "login")
        sharedDefaults.set(password, forKey: "password")
    }
    
    static func clearPassword() {
        sharedDefaults.set(nil, forKey: "password")
    }
    
    static var username = ""
    
    static var hideSubjects: Bool {
        get { !sharedDefaults.bool(forKey: "hideSubjects") }
        set { sharedDefaults.set(!newValue, forKey: "hideSubjects") }
    }
    
    static var showNormalTitle: Bool {
        get { !sharedDefaults.bool(forKey: "showNormalTitle") }
        set { sharedDefaults.set(!newValue, forKey: "showNormalTitle") }
    }
    
    static var scanRating: Bool {
        get { sharedDefaults.bool(forKey: "scanRating") }
        set { sharedDefaults.set(newValue, forKey: "scanRating") }
    }
    
    static let markA = UIColor(named: "markA")!
    static let markB = UIColor(named: "markB")!
    static let markC = UIColor(named: "markC")!
    static let markD = UIColor(named: "markD")!
    
    static func getCircleConfig(subject: subject) -> (circleColor: UIColor, labelColor: UIColor) {
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
