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
    
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var semestrsBarButton: UIBarButtonItem!
    
    var data: [DataManager.subject] = [] {
        didSet {
            if DataManager.hideSubjects { data.removeAll { $0.isHidden() } }
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
            present(loginVC, animated: false)
            return
        }
        settingsBarButton.isEnabled = false
        semestrsBarButton.isEnabled = false
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        tableView.separatorStyle = .none
        tableView.backgroundView = activityIndicator
        
        refreshData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let user = DataManager.getUser()
        if user.password.isEmpty {
            let loginVC = self.storyboard?.instantiateViewController(identifier: "loginVC") as! LoginController
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
            return
        }
        
        super.viewWillAppear(animated)
        data = DataManager.subjects
        navigationItem.title = DataManager.currentSemestr
        tableView.reloadData()
    }
    
    @IBAction func chooseSemestr(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for semestr in DataManager.semestrs {
            alert.addAction(.init(title: semestr.title, style: .default, handler: { (action) in
                NetworkManager.setSemestr(id: semestr.id) {
                    self.refreshData()
                }
            }))
        }
        alert.addAction(.init(title: "Отмена", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc func refreshData() {
        NetworkManager.connect { response in
            if response == .success {
                self.data = DataManager.subjects
                self.tableView.separatorStyle = .singleLine
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.navigationItem.title = DataManager.currentSemestr
                self.settingsBarButton.isEnabled = true
                self.semestrsBarButton.isEnabled = true
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
        let subject = data[indexPath.row]

        let renameAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
            handler(true)
            let alert = UIAlertController(title: "Переименовать дисциплину", message: "Введите новое название, которое будет отображаться в приложении.", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)

            alert.addAction(.init(title: "Переименовать", style: .default, handler: { (action) in
                if let text = alert.textFields?.first?.text {
                    DataManager.sharedDefaults.set(text, forKey: "rename \(subject.title)")
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }))
            alert.preferredAction = alert.actions.first

            if subject.title != subject.getTitle() {
                alert.addAction(.init(title: "По умолчанию", style: .default, handler: { (action) in
                    UserDefaults.standard.set(nil, forKey: "rename \(subject.title)")
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }))
            }

            alert.addAction(.init(title: "Отмена", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        renameAction.image = UIImage(systemName: "square.and.pencil")
        renameAction.backgroundColor = .systemOrange

        let hideAction = UIContextualAction(style: .destructive, title: nil) { (action, view, handler) in
            handler(true)
            DataManager.sharedDefaults.set(!subject.isHidden(), forKey: "hidden \(subject.link)")
            if DataManager.hideSubjects {
                self.data.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        let imageName = subject.isHidden() ? "eye" : "eye.slash"
        hideAction.image = UIImage(systemName: imageName)

        if DataManager.showNormalTitle {
            return UISwipeActionsConfiguration(actions: [hideAction, renameAction])
        } else {
            return UISwipeActionsConfiguration(actions: [hideAction])
        }
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
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let subject = data[indexPath.row]
        
        let configuration = UIContextMenuConfiguration(identifier: String(indexPath.row) as NSCopying, previewProvider: nil) { suggestedActions in
            let renameAction = UIAction(title: "Переименовать", image: UIImage(systemName: "square.and.pencil")) { action in
                let alert = UIAlertController(title: "Переименовать дисциплину", message: "Введите новое название, которое будет отображаться в приложении.", preferredStyle: .alert)
                alert.addTextField(configurationHandler: nil)
                
                alert.addAction(.init(title: "Переименовать", style: .default, handler: { (action) in
                    if let text = alert.textFields?.first?.text {
                        DataManager.sharedDefaults.set(text, forKey: "rename \(subject.title)")
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }))
                alert.preferredAction = alert.actions.first
                if subject.title != subject.getTitle() {
                    alert.addAction(.init(title: "По умолчанию", style: .default, handler: { (action) in
                        UserDefaults.standard.set(nil, forKey: "rename \(subject.title)")
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }))
                }
                alert.addAction(.init(title: "Отмена", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            
            let defaultName = UIAction(title: "Название по умолчанию", image: UIImage(systemName: "return")) { action in
                DataManager.sharedDefaults.set(nil, forKey: "rename \(subject.title)")
                self.updateTableView(indexPath: indexPath)
            }
            
            let defaultChildrens = subject.title == subject.getTitle() ? [renameAction] : [renameAction, defaultName]
            let defaultMenu = UIMenu(title: "", options: .displayInline, children: defaultChildrens)
                
            let hideConfiguration = subject.isHidden() ? ("Показать", "eye") : ("Скрыть", "eye.slash")
            let hideAction = UIAction(title: hideConfiguration.0, image: UIImage(systemName: hideConfiguration.1), attributes: .destructive) { action in
                DataManager.sharedDefaults.set(!subject.isHidden(), forKey: "hidden \(subject.link)")
                if DataManager.hideSubjects {
                    self.updateTableView(indexPath: indexPath, delete: true)
                } else {
                    self.updateTableView(indexPath: indexPath)
                }
            }
            let mainMenuChildrens = DataManager.showNormalTitle ? [defaultMenu, hideAction] : [hideAction]
            return UIMenu(title: "", children: mainMenuChildrens)
        }
        return configuration
    }
    
    private func updateTableView(indexPath: IndexPath, delete: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if delete {
                self.data.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSeg" {
            let destinationVC = segue.destination as! DetailSubjectContoller
            let subject = data[sender as! Int]
            destinationVC.subject = subject
        }
    }
}
