//
//  LoginController.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 07.03.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        LoginManager.test()
//        DownloadController.test()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: UIButton) {
        sender.isEnabled = false
        LoginManager.connect { response in
            if response == .success {
                print("success")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                sender.isEnabled = true
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
