//
//  AppDelegate.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 06.03.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import BackgroundTasks
import Alamofire
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    let notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register( forTaskWithIdentifier: "sergeykorshunov.Grade-SFedU.checkup", using: DispatchQueue.global())
        { task in
            self.updateRating(task as! BGAppRefreshTask)
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if DataManager.scanRating {
            DataManager.saveTotalRating()
            scheduleAppRefresh()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        notificationCenter.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if DataManager.scanRating {
            scheduleNotification(title: "Приложение было закрыто. Для того, чтобы использовать режим ожидания откройте его снова и оставьте свернутым.")
        }
    }
    
    // MARK: - Background Task
    
    private func updateRating(_ task: BGAppRefreshTask) {
        task.expirationHandler = {
            AF.cancelAllRequests()
            self.scheduleNotification(title: "Не удалось обновить баллы")
            task.setTaskCompleted(success: false)
        }
        NetworkManager.connect { status in
            if status == .success {
                if DataManager.compareTotalRating() {
                    self.scheduleNotification()
                    DataManager.saveTotalRating()
                }
                self.scheduleAppRefresh()
                task.setTaskCompleted(success: true)
            } else {
                self.scheduleNotification(title: "Не удалось обновить баллы")
                task.setTaskCompleted(success: false)
            }
        }
    }

    private func scheduleAppRefresh() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: "sergeykorshunov.Grade-SFedU.checkup")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Notifications
    
    private func requestNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func scheduleNotification(title: String = "Выставлены новые баллы") {
        let content = UNMutableNotificationContent()
        content.title = "Grade SFedU"
        content.body = title
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "sergeykorshunov.Grade-SFedU.newRating", content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

