//
//  DataManager.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 04.05.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation

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
}
