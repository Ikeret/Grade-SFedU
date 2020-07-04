//
//  DownloadContoller.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 14.03.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

class DownloadController {
    static let basicURL = "http://grade.sfedu.ru"
    
    public static func loadDiscipline(discipline: String, completionHandler: @escaping ([DataManager.module]) -> Void) {

        AF.request(basicURL + discipline).response { response in
            
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
