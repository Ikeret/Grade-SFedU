//
//  LoginManager.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 07.03.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import SwiftSoup
import Alamofire

class LoginManager {
    public static var token: String?
    
    public static var login: String = "serkorshunov"
    public static var password: String = "korshunov65"
    
    public static func connect() -> Bool {
        AF.request("https://openid.sfedu.ru/server.php/login", method: .post,
                   parameters: ["openid_url": login, "password": password], encoder: URLEncodedFormParameterEncoder.default).response { response in
//                       debugPrint(response)
                    }
        AF.request("http://grade.sfedu.ru/handler/sign/openidlogin?loginopenid=" + login).response { response in
//            debugPrint(response)
        }
        
        return false
    }
}
