//
//  NotificationSettingTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 28/5/2022.
//

import UIKit

class NotifcationSwitchTableCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
}

class NotificationSettingTableViewController: UITableViewController {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private let sections = ["User Settings", "App Settings"]
    
    private let rows = [
        ["Change notifcation settings", "Test notification"],
        ["Game alerts", "Favourites only"]
    ]
    
    private let settingCellIdentifer = "settingsCell"
    private let optionCellIdentifier = "optionCell"
    private let userSettingSection = 0
    private let settingsRow = 0
    private let gameAlertRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        getNotificationSettings(update: false)
    }

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
        if indexPath.row == settingsRow {
            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            } // src: https://stackoverflow.com/questions/42848539/opening-apps-notification-settings-in-the-settings-app
        }
        else {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
