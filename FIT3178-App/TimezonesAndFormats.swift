//
//  TimezoneConverter.swift
//  All-NBA
//
//  Created by Samir Gupta on 18/5/2022.
//

import Foundation
import UIKit

/// Holds the formats used throughout the App.
public enum DateFormats: String {
    
    /// The format that is used by the App's API (e.g. 2022-04-12).
    case API = "yyyy-MM-dd"
    
    /// The format used to display the Day, Date and Month to the user (e.g. Tuesday, 12 April).
    case display = "EEEE, d MMM"
    
    /// The format used for 24-hour time (e.g. 08:00 or 20:00).
    case time24hr = "HH:mm"
    
    /// The format used for 12-hour time (e.g. 08:00AM or 08:00PM).
    case time12hr = "HH:mma"
}

/// Holds the indentifiers for the App's commonly used timezones.
public enum TimeZoneIdentifiers: String {
    
    /// The App's origin timezone identifier.
    case aus_melb = "Australia/Melbourne"
    
    /// The App's API's timezone identifier.
    case usa_nyk = "America/New_York"
}

public extension DateFormatter {
    
    /// Converts a string into a date with a specified timezone.
    ///
    /// - Parameters:
    ///    - string: the string to convert.
    ///    - format: the case of ``DateFormats`` `string` is in.
    ///    - timezone: the identifier of the timezone to convert to.
    /// - Returns: The Date object representing the date in `string` with the specified timezone.
    func stringToDate(string: String, format: DateFormats, timezone: String) -> Date {
        self.dateFormat = format.rawValue
        self.timeZone = TimeZone(identifier: timezone)
        return self.date(from: string)!
    }
    
    /// Converts a date into a string with a specified timezone.
    ///
    /// - Parameters:
    ///    - date: the date to convert.
    ///    - format: the case of ``DateFormats`` that represents the format to return the String in.
    ///    - timezone: the identifier of the timezone to convert to.
    /// - Returns: A string representing the `date` with the specified timezone in the specified format.
    func dateToString(date: Date, format: DateFormats, timezone: String) -> String {
        self.dateFormat = format.rawValue
        self.timeZone = TimeZone(identifier: timezone)
        return self.string(from: date)
    }
}

/// Function to convert a stringed date between two timezones.
///
///  - Parameters:
///     - string: the stringed date to convert.
///     - from: the identifier of the timezone converting from.
///     - to: the identifier of the timezone converting to.
///     - format: the case of ``DateFormats`` representing the format of `string`.
///  - Returns: A Date  object representing the converted date.
public func convertTimeZones(string: String, from: String, to: String, format: DateFormats) -> Date {
    let from = TimeZone(identifier: from)!
    let to = TimeZone(identifier: to)!
    let diff = to.secondsFromGMT() - from.secondsFromGMT()
    let formatter = DateFormatter()
    formatter.dateFormat = format.rawValue
    let date = formatter.date(from: string)!
    return date.addingTimeInterval(TimeInterval(diff))
}

/// Converts a specific stringed time from 12hr time to 24hr time.
///
/// String needs to be in the format "HH:mm a", where 'HH' represents hours, 'mm' represents minutes and 'a' represents either "AM" or "PM".
///
/// - Parameters:
///    - string: the 12hr time to convert.
/// - Returns: the converted 24hr time.
public func convertTo24HourTime(string: String) -> String {
    if !string.contains(":") || !string.contains(" ") { return "Error" }
    
    let split = string.split(separator: " ")
    let gameTimeSplit = split[0].split(separator: ":")
    var hour = gameTimeSplit[0]
    
    if (split[1].uppercased() == "PM" && hour != "12") {
        hour = "\(Int(hour)! + 12)"
    }
    if (split[1].uppercased() == "AM" && hour == "12") {
        hour = "00"
    }
    if hour.count != 2 { hour = "0" + hour }
    
    return "\(hour):\(gameTimeSplit[1])"
}

/// Converts a stringed time from the  API's US timezone into the current time zone, and then converts it to 24hr time and in a pretty print format to display.
///
/// String needs to be in the format "HH:mm a", where 'HH' represents hours, 'mm' represents minutes and 'a' represents either "AM" or "PM".
///
/// - Parameters:
///    - string: the stringed time to convert.
/// - Returns: the converted pretty print time.
func APItoCurrentTimeZoneDisplay(string: String) -> String {
    let timeString = convertTo24HourTime(string: string)
    let newTime = convertTimeZones(string: timeString, from: TimeZoneIdentifiers.usa_nyk.rawValue, to: (UIApplication.shared.delegate as! AppDelegate).currentTimeZoneIdentifier, format: .time24hr)
    let formatter = DateFormatter()
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    formatter.dateFormat = DateFormats.time12hr.rawValue
    return formatter.string(from: newTime)
}
