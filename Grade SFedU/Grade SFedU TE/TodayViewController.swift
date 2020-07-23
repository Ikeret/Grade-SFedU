//
//  TodayViewController.swift
//  Grade SFedU TE
//
//  Created by Сергей Коршунов on 05.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding {
    
    var data: [DataManager.subject] = [] {
        didSet {
            data.removeAll { $0.isHidden() }
        }
    }
    
    var errorInLoading = false
    var dataLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        tableView.register(UINib(nibName: TodayCompactCell.id, bundle: Bundle.main), forCellReuseIdentifier: TodayCompactCell.id)
        tableView.register(UINib(nibName: TodaySubjectCell.id, bundle: Bundle.main), forCellReuseIdentifier: TodaySubjectCell.id)
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        NetworkManager.connect { status in
            
            self.data = DataManager.subjects
            self.tableView.reloadData()
            if status != .success {
                self.errorInLoading = true
            } else {
                if self.extensionContext!.widgetActiveDisplayMode == .expanded {
                    self.preferredContentSize = self.tableView.contentSize
                }
            }
            self.dataLoaded = true
            completionHandler(.newData)
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        tableView.reloadData()
        if activeDisplayMode == .expanded {
            preferredContentSize = tableView.contentSize
        }
        else if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
    }
    
    @objc func refreshData() {
        NetworkManager.connect { status in
            if status != .success {
                self.errorInLoading = true
            }
            self.data = DataManager.subjects
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(data.count, 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if data.isEmpty || (!data.isEmpty && extensionContext!.widgetActiveDisplayMode == .compact) {
            let cell = tableView.dequeueReusableCell(withIdentifier: TodayCompactCell.id, for: indexPath) as! TodayCompactCell
            guard dataLoaded else {
                return cell
            }
            let username = DataManager.username
            if !errorInLoading && !username.isEmpty {
                cell.titleLabel.text = username
                cell.subtitleLabel.text = "Раскройте виджет, чтобы увидеть список предметов"
                cell.subtitleLabel.textColor = .label
            } else {
                cell.titleLabel.text = "Ошибка"
                cell.subtitleLabel.text = "Произошла ошибка при загрузке данных"
                cell.subtitleLabel.textColor = .systemRed
                cell.refreshButton.isHidden = false
                cell.refreshButton.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
            }
            
            cell.subtitleLabel.isHidden = false
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TodaySubjectCell.id, for: indexPath) as! TodaySubjectCell
        cell.titleLabel.text = data[indexPath.row].getTitle()
        cell.ratingLabel.text = data[indexPath.row].rate
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let url = URL(string: "grade-sfedu:")!
        extensionContext?.open(url)
    }
}
