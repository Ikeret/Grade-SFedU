//
//  NetworkManager.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 07.03.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

class NetworkManager {
    static let basicURL = "http://grade.sfedu.ru"
    
    enum LoginStatus: String {
        case success = ""
        case wrongPassword = "Неверный логин и/или пароль. Повторите попытку."
        case noNetworkConnection = "Нет подключения к интернету. Проверьте настройки сети."
        case connectionTimedOut = "Превышено время ожидания от сервера. Возможно, сайт в настоящее время недоступен."
    }
    
    static func connect(completionHandler: @escaping (LoginStatus) -> Void) {
        guard NetworkReachabilityManager()?.isReachable ?? false else {
            completionHandler(.noNetworkConnection)
            return
        }
        
        guard DataManager.isExpire() else {
            AF.request(basicURL).response { response in
                if response.error != nil {
                    completionHandler(.connectionTimedOut)
                    return
                }
                let html = String(data: response.data!, encoding: .utf8)!
                
                parseHTML(html: html)
                completionHandler(.success)
            }
            return
        }
        
        let user = DataManager.getUser()
        
        AF.request("https://openid.sfedu.ru/server.php/login", method: .post, parameters: ["openid_url": user.login, "password": user.password], encoder: URLEncodedFormParameterEncoder.default).response { response in
            
            if response.error != nil {
                completionHandler(.connectionTimedOut)
                return
            }
            
            let html = String(data: response.data!, encoding: .utf8)!
            
            
            if let doc = try? HTML(html: html, encoding: .utf8) {
                if doc.title != "Административный портал ЮФУ" {
                    completionHandler(.wrongPassword)
                    return
                }
            }
            
            AF.request(basicURL + "/handler/sign/openidlogin?loginopenid=\(user.login)&user_role=student").response { response in
                if response.error != nil {
                    completionHandler(.connectionTimedOut)
                    return
                }
                DataManager.expireCookie = Date().timeIntervalSince1970 + 1500
                
                let html = String(data: response.data!, encoding: .utf8)!
                
                parseHTML(html: html)
                completionHandler(.success)
            }
        }
    }
    
    static func resignIfNeeded(completionHandler: @escaping (LoginStatus) -> Void) {
        guard NetworkReachabilityManager()?.isReachable ?? false else {
            completionHandler(.noNetworkConnection)
            return
        }
        
        guard DataManager.isExpire() else {
            completionHandler(.success)
            return
        }
        
        let user = DataManager.getUser()
        AF.request("https://openid.sfedu.ru/server.php/login", method: .post, parameters: ["openid_url": user.login, "password": user.password], encoder: URLEncodedFormParameterEncoder.default).response { response in
            if response.error != nil {
                completionHandler(.connectionTimedOut)
                return
            }
            let html = String(data: response.data!, encoding: .utf8)!
            if let doc = try? HTML(html: html, encoding: .utf8) {
                if doc.title != "Административный портал ЮФУ" {
                    completionHandler(.wrongPassword)
                    return
                }
            }
            
            AF.request(basicURL + "/handler/sign/openidlogin?loginopenid=\(user.login)&user_role=student").response { response in
                if response.error != nil {
                    completionHandler(.connectionTimedOut)
                    return
                }
                DataManager.expireCookie = Date().timeIntervalSince1970 + 1500
                completionHandler(.success)
            }
        }
    }
    
    private static func parseHTML(html: String) {
        let doc = try! HTML(html: html, encoding: .utf8)
        
        var marks = doc.css("span").filter({ (element) -> Bool in
            return element.text!.allSatisfy { (char) -> Bool in
                return char.isNumber
            }
        }).enumerated().compactMap {$0.offset % 3 == 2 ? nil : $0.element }
        
        var types = [String]()
        for node in doc.css(".discControl") {
            types.append(node.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        types.removeFirst()
        
        DataManager.subjects.removeAll()
        for node in doc.css("a, link") {
            let title = node.text!
            let link = node["href"]!
            if (link.hasPrefix("/student/discipline/")) {
                let currentMark = marks.remove(at: 0).text!
                let maxMark = marks.remove(at: 0).text!
                DataManager.subjects.append(.init(title: title, link: link, rate: currentMark, maxRate: maxMark, type: types.removeFirst()))
            }
        }
        DataManager.semestrs.removeAll()
        for node in doc.css("a, link") {
            if let id = node["id"]?.trimmingCharacters(in: .whitespacesAndNewlines), id.hasPrefix("S") {
                let title = node.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
                DataManager.semestrs.append(.init(title: title, id: String(id.split(separator: "-").last!)))
            }
        }
        
        DataManager.currentSemestr = doc.at_css(".semesterChangerSelection")?.text ?? ""
        DataManager.username = doc.at_xpath("//*[@id=\"username\"]")?.text ?? ""
    }
    
    static func setSemestr(id: String, completionHandler: @escaping () -> Void) {
        AF.request("https://grade.sfedu.ru/handler/Settings/setSemesterID", method: .post, parameters: ["id": id], encoder: URLEncodedFormParameterEncoder.default).response { response in
            if response.error != nil {
                return
            }
            completionHandler()
        }
    }
    
    static func signOut() {
        DataManager.expireCookie = 0
        DataManager.clearPassword()
    }
    
    static func loadDiscipline(discipline: String, completionHandler: @escaping ([DataManager.module]) -> Void) {
        
        AF.request(basicURL + discipline).response { response in
            if response.error != nil {
                completionHandler([])
                return
            }
            let html = String(data: response.data!, encoding: .utf8)!
            if let doc = try? HTML(html: html, encoding: .utf8) {
                var moduleTitles = [String]()
                for node in doc.css(".tableTitle, .totalRate") {
                    moduleTitles.append(node.text!.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                var textData = [String]()
                for node in doc.css(".tableTitle, .submoduleTitle, .submoduleRate, .submoduleDate, .totalRate") {
                    let string = node.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    textData.append(string)
                }
                
                var result = [DataManager.module]()
                
                while !textData.isEmpty {
                    let title = moduleTitles.removeFirst()
                    textData.removeFirst()
                    if title.hasPrefix("Промежуточный итог") || title.hasPrefix("Итоговый рейтинг") {
                        result.append(.init(title: "", submoles: [.init(title: title, rate: "", date: "")]))
                        continue
                    }
                    var module = DataManager.module(title: title, submoles: [])
                    while textData.first != moduleTitles.first {
                        module.submoles.append(.init(title: textData.removeFirst(), rate: textData.removeFirst(), date: textData.removeFirst()))
                    }
                    result.append(module)
                }
                completionHandler(result)
            }
        }
    }
}
