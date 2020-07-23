//
//  SettingsController.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 07.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import SafariServices
import UserNotifications

class SettingsController: UITableViewController {

    @IBOutlet weak var hideSwitcher: UISwitch!
    @IBOutlet weak var renameSwitcher: UISwitch!
    @IBOutlet weak var scanSwitcher: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = DataManager.username
        hideSwitcher.isOn = !DataManager.hideSubjects
        renameSwitcher.isOn = DataManager.showNormalTitle
        scanSwitcher.isOn = DataManager.scanRating
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func setHide(_ sender: UISwitch) {
        DataManager.hideSubjects.toggle()
    }
    
    @IBAction func setRename(_ sender: UISwitch) {
        DataManager.showNormalTitle.toggle()
    }
    
    @IBAction func setScan(_ sender: UISwitch) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    DataManager.scanRating.toggle()
                } else {
                    
                    sender.setOn(false, animated: true)
                    
                    let alert = UIAlertController(title: "Ошибка", message: "Уведомления для данного приложения выключены. Вам необходимо включить их в настройках.", preferredStyle: .alert)
                    alert.addAction(.init(title: "ОК", style: .cancel, handler: nil))
                    alert.addAction(.init(title: "Настройки", style: .default, handler: { (action) in
                        if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                            if UIApplication.shared.canOpenURL(appSettings) {
                                UIApplication.shared.open(appSettings)
                            }
                        }
                    }))
                    self.present(alert, animated: true)
                }
                
                if let error = error {
                    print(error.localizedDescription)
                    sender.setOn(false, animated: true)
                }
            }
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        DataManager.clearPassword()
        NetworkManager.signOut()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openInBrowser() {
        let url = URL(string: "http://grade.sfedu.ru")!
        let chromeUrl = URL(string: "googlechrome://grade.sfedu.ru")!
        
        if UIApplication.shared.canOpenURL(chromeUrl) {
            UIApplication.shared.open(chromeUrl)
        } else {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
}
