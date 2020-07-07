//
//  LoginController.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 07.03.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class LoginController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.addSubview(activityIndicator)
        activityIndicator.center.x = view.center.x + 20
        activityIndicator.center.y = loginButton.frame.height / 2
        activityIndicator.hidesWhenStopped = true
        
        loginTextField.delegate = self
        passwordTextField.delegate = self
        
        let user = DataManager.getUser()
        loginTextField.text = user.login
        
        loginTextField.addTarget(self, action: #selector(textFieldStopEditing), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldStopEditing), for: .editingChanged)
    }
    
    @objc func textFieldStopEditing() {
        guard let login = loginTextField.text, let password = passwordTextField.text else {
            loginButton.isEnabled = false
            return
        }
        
        if !login.isEmpty && !password.isEmpty {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
    @IBAction func login(_ sender: Any?) {
        activityIndicator.startAnimating()
        loginButton.isEnabled = false
        
        DataManager.setUser(login: loginTextField.text, password: passwordTextField.text)
        
        NetworkManager.connect { response in
            if response == .success {
                self.dismiss(animated: true, completion: nil)
            } else {
                let banner = FloatingNotificationBanner(title: "Ошибка", subtitle: response.rawValue, style: .danger)
                banner.haptic = .heavy
                banner.show(queuePosition: .front, bannerPosition: .top, cornerRadius: 10, shadowBlurRadius: 15)
                self.loginButton.isEnabled = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            login(nil)
        }
        return true
    }
}
