//
//  LoginManager.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 07.03.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
//import SwiftSoup
import Alamofire
import Kanna



class LoginManager {
    
    public static var login: String = "serkorshunov"
    public static var password: String = "korshunov65"
    
    enum LoginStatus {
        case success
        case wrongPassword
        case noNetworkConnection
        case unknow
    }
    
    
    public static func test() {
//        guard let doc: Document = try? SwiftSoup.parse(testString) else { return }
//        var elements = try? doc.select("a, link")
//
//            for element in elements! {
//                for textNode in element.textNodes() {
//                    print(textNode)
//                }
//            }
//        elements = try? doc.select("div.main_content > a")
//
//            for element in elements! {
//                for textNode in element.textNodes() {
//                    print(textNode)
//                }
//            }
        
    }
    
    
    public static func connect(completionHandler: @escaping (LoginStatus) -> Void) {
        
        
        
        
        AF.request("https://openid.sfedu.ru/server.php/login", method: .post, parameters: ["openid_url": login, "password": password], encoder: URLEncodedFormParameterEncoder.default).response { response in
//            debugPrint(response)
            
//            completionHandler(.success)
            
                AF.request("http://grade.sfedu.ru/handler/sign/openidlogin?loginopenid=" + login + "&user_role=student").response { response in
//                    debugPrint(response)

                        var html = String(data: response.data!, encoding: .utf8)!
//                    html.rem
//                    print(html)
//                    guard let doc: Document = try? SwiftSoup.parse(html) else { return }
//                    var elements = try? doc.select("a, link")
//
//                        for element in elements! {
//                            for textNode in element.textNodes() {
//                                print(textNode)
//                            }
//                        }
//                    elements = try? doc.select("div.main_content > a")
//
//                        for element in elements! {
//                            for textNode in element.textNodes() {
//                                print(textNode)
//                            }
//                        }
                    
                    if let doc = try? HTML(html: html, encoding: .utf8) {
//
                        var marks = doc.css("span").filter({ (element) -> Bool in
                            return element.text!.allSatisfy { (char) -> Bool in
                                return char.isNumber
                            }
                        }).enumerated().compactMap {$0.offset % 3 == 2 ? nil : $0.element }
                        
                        
                        
                        for node in doc.css("a, link") {
                            let title = node.text!
                            let link = node["href"]!
                            if (link.hasPrefix("/student/discipline/")) {
                                let currentMark = marks.remove(at: 0).text!
                                let maxMark = marks.remove(at: 0).text!
                                subjects.append(.init(title: title, link: link, currentMark: currentMark, maxMark: maxMark))
                            }
                        }
                        
                        print(subjects)
                        completionHandler(.success)

                     
                    }
            }
        }
        
        
    }
}
