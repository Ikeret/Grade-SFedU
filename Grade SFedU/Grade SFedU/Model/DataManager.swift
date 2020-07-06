//
//  DataManager.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 04.05.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit

class DataManager {
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
        
        func getNormalTitle() -> String {
            return UserDefaults.standard.string(forKey: "rename \(title)") ?? title
        }
        
        func isHidden() -> Bool {
            return UserDefaults.standard.bool(forKey: "hidden \(link)")
        }
    }
    
    static var subjects = [subject]()
    
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
        let login = UserDefaults.standard.string(forKey: "login") ?? ""
        let password = UserDefaults.standard.string(forKey: "password") ?? ""
        
        return (login, password)
    }
    
    static func setUser(login: String?, password: String?) {
        UserDefaults.standard.set(login, forKey: "login")
        UserDefaults.standard.set(password, forKey: "password")
    }
    
    static func clearPassword() {
        UserDefaults.standard.set(nil, forKey: "password")
    }
    
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
