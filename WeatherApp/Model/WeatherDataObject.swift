//
//  WeatherDataObject.swift
//  WeatherApp
//
//  Created by Sharat Guduru on 8/12/24.
//

import Foundation
class WeatherDataObject {
    var weather: WeatherResponse
    
    init(_ weather: WeatherResponse) {
        self.weather = weather
    }
    
    var dateText: String {
        return String(weather.dt_txt?.prefix(10) ?? "")
    }
    var dayDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateText) ?? Date()
        return date
    }
    var iconImage: String {
        return "https://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png"
    }
    
    var weatherDesc: String {
        return weather.weather.first?.main ?? "Unkown"
    }
    
    var cityName: String {
        return weather.name ?? "Unkown"
    }
    
    var temperature: String {
        return "\(Number.numberFormatter.string(for: weather.main.temp) ?? "0")°"
    }
    
    var high: String {
        return "H: \(Number.numberFormatter.string(for: weather.main.tempMax) ?? "0")°"
    }
    
    var low: String {
        return "L: \(Number.numberFormatter.string(for: weather.main.tempMin) ?? "0")°"
    }
    
    var hourLabel: String {
        return Time.timeFormatter.string(from: weather.dt)
    }
    
    var weekDay: String {
        return Time.dayFormatter.string(from: dayDate)
    }
    
    var dayNumber: String {
        return Time.dayNumberFormatter.string(from:dayDate)
    }
}

class Number{
    static var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }
    
    static var numberFormatter2: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        return numberFormatter
    }
}

class Time {
    static let defaultDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()

    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    static let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh a"
        return formatter
    }()
}
