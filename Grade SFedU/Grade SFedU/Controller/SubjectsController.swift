//
//  SubjectsController.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 10.03.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class SubjectsController: UITableViewController {
    
    var data: [DataManager.subject] = [] {
        didSet {
            data.removeAll { $0.isHidden() }
        }
    }
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: SubjectCell.id, bundle: Bundle.main), forCellReuseIdentifier: SubjectCell.id)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        let user = DataManager.getUser()
        if user.password.isEmpty {
            let loginVC = self.storyboard?.instantiateViewController(identifier: "loginVC") as! LoginController
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false, completion: nil)
            return
        }
        
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        tableView.separatorStyle = .none
        tableView.backgroundView = activityIndicator
        
        refreshData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        data = DataManager.subjects
        navigationItem.title = DataManager.currentSemestr
        tableView.reloadData()
    }
    
    @IBAction func chooseSemestr(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for semestr in DataManager.semestrs {
            alert.addAction(.init(title: semestr.title, style: .default, handler: { (action) in
                LoginManager.setSemestr(id: semestr.id) {
                    self.refreshData()
                }
            }))
        }
        alert.addAction(.init(title: "Отмена", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func refreshData() {
        LoginManager.connect { response in
            if response == .success {
                self.data = DataManager.subjects
                self.tableView.separatorStyle = .singleLine
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.navigationItem.title = DataManager.currentSemestr
            } else if response == .noNetworkConnection {
                let banner = FloatingNotificationBanner(title: "Ошибка", subtitle: response.rawValue, style: .warning)
                banner.haptic = .heavy
                banner.show(queuePosition: .front, bannerPosition: .top, cornerRadius: 10, shadowBlurRadius: 15)
                self.refreshControl?.endRefreshing()
            } else {
                let loginVC = self.storyboard?.instantiateViewController(identifier: "loginVC") as! LoginController
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: {
                    let banner = FloatingNotificationBanner(title: "Ошибка", subtitle: response.rawValue, style: .danger)
                    banner.haptic = .heavy
                    banner.show(queuePosition: .front, bannerPosition: .top, cornerRadius: 10, shadowBlurRadius: 15)
                    self.tableView.separatorStyle = .singleLine
                    self.activityIndicator.stopAnimating()
                    self.refreshControl?.endRefreshing()
                })
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubjectCell.id) as! SubjectCell
        cell.configure(subject: data[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "detailSeg", sender: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renameAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
            handler(true)
            let alert = UIAlertController(title: "Переименовать дисциплину", message: "Введите новое название, которое будет отображаться в приложении.", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textField in
                textField.text = self.data[indexPath.row].title
                textField.clearButtonMode = .whileEditing
            })
            alert.addAction(.init(title: "ОК", style: .default, handler: { (action) in
                if let text = alert.textFields?.first?.text {
                    UserDefaults.standard.set(text, forKey: "rename \(self.data[indexPath.row].title)")
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }))
            alert.addAction(.init(title: "Отмена", style: .destructive, handler: nil))
            self.present(alert, animated: true)
        }
        renameAction.image = UIImage(systemName: "pencil")
        renameAction.backgroundColor = .systemOrange
        
        let hideAction = UIContextualAction(style: .destructive, title: nil) { (action, view, handler) in
            handler(true)
            UserDefaults.standard.set(true, forKey: "hidden \(self.data[indexPath.row].link)")
            self.data.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        hideAction.image = UIImage(systemName: "eye.slash")
        
        return UISwipeActionsConfiguration(actions: [hideAction, renameAction])
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0.1))
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0.1))
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSeg" {
            let destinationVC = segue.destination as! DetailSubjectContoller
            destinationVC.subject = data[sender as! Int]
        }
    }
}
