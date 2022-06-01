//
//  NotificationSettingTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 28/5/2022.
//

import UIKit

/// Custom cell to display a notification setting and a switch.
class NotifcationSwitchTableCell: UITableViewCell {
    /// Label describing the setting.
    @IBOutlet weak var label: UILabel!
    /// Switch used to determine if the setting is on or off.
    @IBOutlet weak var cellSwitch: UISwitch!
}

/// Custom class to be able to edit the notification settings in the App.
class NotificationSettingTableViewController: UITableViewController {
    /// Variable to access the ``AppDelegate`` in the App.
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    /// The sections of the table view.
    private let sections = ["User Settings", "App Settings"]
    /// The row titles of the rows in the table view.
    private let rows = [
        ["Change notifcation settings", "Test notification"],
        ["Game alerts", "Favourites only"]
    ]
    /// The setting cell identifier.
    private let settingCellIdentifer = "settingsCell"
    /// The option cell identifier.
    private let optionCellIdentifier = "optionCell"
    /// The section that houses the user settings.
    private let userSettingSection = 0
    /// The row that links to the device's settings. [Source found here.](https://stackoverflow.com/questions/42848539/opening-apps-notification-settings-in-the-settings-app)
    private let settingsRow = 0
    /// The row that houses the game alert switch.
    private let gameAlertRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        getNotificationSettings(update: false)
    }

    /// Action to update the ``AppDelegate`` on changes to the notification settings.
    /// - Parameters:
    ///     - sender: The triggerer of this action.
    @IBAction func switchChanged(_ sender: Any) {
        let sender = sender as! UISwitch
        if sender.tag == gameAlertRow {
            appDelegate.gameAlertNotifcations = sender.isOn
        }
        else {
            appDelegate.favouritesOnlyNotifications = sender.isOn
        }
        getNotificationSettings(update: true)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == userSettingSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: settingCellIdentifer, for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = rows[indexPath.section][indexPath.row]
            
            if indexPath.row == settingsRow {
                var subtitle = "Notifcations are currently: "
                subtitle += appDelegate.notificationsEnabled ? "On" : "Off"
                content.secondaryText = subtitle
            }
            
            cell.contentConfiguration = content
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: optionCellIdentifier, for: indexPath) as! NotifcationSwitchTableCell

        cell.label.text = rows[indexPath.section][indexPath.row]
        cell.cellSwitch.tag = indexPath.row
        if indexPath.row == gameAlertRow {
            cell.cellSwitch.isOn = appDelegate.gameAlertNotifcations
        }
        else {
            cell.cellSwitch.isOn = appDelegate.favouritesOnlyNotifications
            cell.isHidden = !appDelegate.gameAlertNotifcations
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].uppercased()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == settingsRow { // go to settings
            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
        else { // queue a dummy notification
            let content = UNMutableNotificationContent()
            content.title = "Game Alert (TEST)"
            content.body = "--- vs --- starting soon"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["testNotification"])
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
