//
//  Weather.swift
//  WeatherApp
//
//  Created by Sharat Guduru on 8/12/24.
//

import Foundation

struct WeatherForcast: Codable {
    let list: [WeatherResponse]
}

struct WeatherResponse: Codable {
    let coord: Coord?
    let weather: [Weather]
    let base: String?
    let main: Main
    let visibility: Int
    let clouds: Clouds
    let dt: Date
    let sys: Sys
    let timezone: Int?
    let id: Int?
    let name: String?
    let cod: Int?
    let dt_txt: String?
}

struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let country: String?
    let sunrise: Int?
    let sunset: Int?
    let pod: String?
}
