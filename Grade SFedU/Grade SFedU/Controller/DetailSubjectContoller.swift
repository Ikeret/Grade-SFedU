//
//  DetailSubjectContoller.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 01.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class DetailSubjectContoller: UITableViewController {

    var subject: DataManager.subject!
    var data = [DataManager.module]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: SubmoduleCell.id, bundle: Bundle.main), forCellReuseIdentifier: SubmoduleCell.id)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.separatorStyle = .none
        refreshData()
    }
    
    @objc func refreshData() {
        NetworkManager.resignIfNeeded { status in
            if status == .success {
                self.loadData()
            } else if status == .noNetworkConnection {
                let banner = FloatingNotificationBanner(title: "Ошибка", subtitle: status.rawValue, style: .warning)
                banner.haptic = .heavy
                banner.show(queuePosition: .front, bannerPosition: .top, cornerRadius: 10, shadowBlurRadius: 15)
            } else {
                let banner = FloatingNotificationBanner(title: "Ошибка", subtitle: status.rawValue, style: .danger)
                banner.haptic = .heavy
                banner.show(queuePosition: .front, bannerPosition: .top, cornerRadius: 10, shadowBlurRadius: 15)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func loadData() {
        NetworkManager.loadDiscipline(discipline: subject.link, completionHandler: { response in
             self.data = response
             self.tableView.reloadData()
             self.refreshControl?.endRefreshing()
             
             self.tableView.separatorStyle = .singleLine
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == data.count { return 0 }
        return data[section].submoles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubmoduleCell.id, for: indexPath) as! SubmoduleCell
        
        let submodule = data[indexPath.section].submoles[indexPath.row]
        cell.configure(title: submodule.title, rate: submodule.rate, date: submodule.date)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].title
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if data[section].submoles.isEmpty {
            return UIView()
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if data[section].submoles.isEmpty {
            return 40
        } else {
            return 0
        }
    }
}
