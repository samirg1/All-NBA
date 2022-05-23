//
//  TimezoneConverter.swift
//  All-NBA
//
//  Created by Samir Gupta on 18/5/2022.
//

import Foundation
import UIKit

public enum DateFormats: String {
    case API = "yyyy-MM-dd"
    case display = "EEEE, d MMM"
    case time24hr = "HH:mm"
    case time12hr = "HH:mma"
    case full = "yyyy-MM-dd-HH:mm"
}

public enum TimeZoneIdentifiers: String {
    case aus_melb = "Australia/Melbourne"
    case usa_nyk = "America/New_York"
}


extension DateFormatter {
    func stringToDate(string: String, format: DateFormats, timezone: String) -> Date {
        self.dateFormat = format.rawValue
        self.timeZone = TimeZone(identifier: timezone)
        return self.date(from: string)!
    }
    func dateToString(date: Date, format: DateFormats, timezone: String) -> String {
        self.dateFormat = format.rawValue
        self.timeZone = TimeZone(identifier: timezone)
        return self.string(from: date)
    }
}

func convertTimeZones(string: String, from: String, to: String, format: DateFormats) -> Date {
    let from = TimeZone(identifier: from)!
    let to = TimeZone(identifier: to)!
    let diff = to.secondsFromGMT() - from.secondsFromGMT()
    let formatter = DateFormatter()
    formatter.dateFormat = format.rawValue
    let date = formatter.date(from: string)!
    return date.addingTimeInterval(TimeInterval(diff))
}

func convertTo24HourTime(string: String) -> String {
    if !string.contains(":") || !string.contains(" ") { return "Error" }
    
    let split = string.split(separator: " ")
    let gameTimeSplit = split[0].split(separator: ":")
    var hour = gameTimeSplit[0]
    
    if split[1] == "PM" { hour = "\(Int(hour)! + 12)" }
    if hour.count != 2 { hour = "0" + hour }
    
    return "\(hour):\(gameTimeSplit[1])"
}

func APItoCurrentTimeZoneDisplay(string: String) -> String {
    let timeString = convertTo24HourTime(string: string)
    let newTime = convertTimeZones(string: timeString, from: TimeZoneIdentifiers.usa_nyk.rawValue, to: (UIApplication.shared.delegate as! AppDelegate).currentTimeZone, format: .time24hr)
    let formatter = DateFormatter()
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    formatter.dateFormat = DateFormats.time12hr.rawValue
    return formatter.string(from: newTime)
}

