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
    var notificationsAllowed = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register( forTaskWithIdentifier: "sergeykorshunov.Grade-SFedU.checkup", using: nil)
        { task in
            self.updateRating(task as! BGAppRefreshTask)
        }
        requestNotifications()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        guard notificationsAllowed else {
            return
        }
        scheduleAppRefresh()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        notificationCenter.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: - Background Task
    
    private func updateRating(_ task: BGAppRefreshTask) {
        task.expirationHandler = {
            AF.cancelAllRequests()
            task.setTaskCompleted(success: false)
        }
//        scheduleNotification()
        task.setTaskCompleted(success: true)

        scheduleAppRefresh()
    }

    private func scheduleAppRefresh() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: "sergeykorshunov.Grade-SFedU.checkup")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 20)
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Notifications
    
    private func requestNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            self.notificationsAllowed = success
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Grade SFedU"
        content.body = "Выставлены новые баллы"
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

