//
//  SettingsController.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 07.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {

    @IBOutlet weak var hideSwitcher: UISwitch!
    @IBOutlet weak var renameSwitcher: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = DataManager.username
        hideSwitcher.isOn = !DataManager.hideSubjects
        renameSwitcher.isOn = DataManager.showNormalTitle
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func setHide(_ sender: UISwitch) {
        DataManager.hideSubjects.toggle()
    }
    
    @IBAction func setRename(_ sender: UISwitch) {
        DataManager.showNormalTitle.toggle()
    }
    
    @IBAction func logOut(_ sender: Any) {
        DataManager.clearPassword()
        NetworkManager.signOut()
        navigationController?.popViewController(animated: true)
    }
}
