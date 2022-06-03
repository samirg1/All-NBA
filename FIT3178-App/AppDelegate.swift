//
//  AppDelegate.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 21/3/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    /// Variable that determines whether the notifications have been enabled on the current device.
    public var notificationsEnabled: Bool = false
    /// Variable to determine whether or not the user has elected to allow Game Alert notifications.
    public var gameAlertNotifcations: Bool = true
    /// Variable to determine whether or not the user has elected to only allow Game Alert notifications from their favourite teams and players.
    public var favouritesOnlyNotifications: Bool = false
    
    /// Variable that determines the identifier of the timezone that the App will show times and dates in.
    public var currentTimeZoneIdentifier = TimeZone.current.identifier
    
    /// The user's favourite teams.
    public var favouriteTeams: [Team] = []
    /// The user's favourite players.
    public var favouritePlayers: [Player] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { notificationSettings in
            if notificationSettings.authorizationStatus == .notDetermined {
                notificationCenter.requestAuthorization(options: [.alert]) { granted, error in
                    self.notificationsEnabled = granted
                    if granted {
                        let notificationCenter = UNUserNotificationCenter.current()
                        notificationCenter.delegate = self
                    }
                }
            }
            else if notificationSettings.authorizationStatus == .authorized {
                self.notificationsEnabled = true
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.delegate = self
            }
        }
        getNotificationSettings(update: false)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
    }
}
