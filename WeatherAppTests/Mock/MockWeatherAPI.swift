//
//  MockWeatherAPI.swift
//  WeatherAppTests
//
//  Created by Sharat Guduru on 8/13/24.
//

import Combine
import CoreLocation
@testable import WeatherApp

class MockWeatherService: WeatherServiceAPIProtocol {
    
    var shouldReturnError = false
    
    func fetchCurrentWeather(for urlString: String) -> AnyPublisher<WeatherResponse, NetworkError> {
        if shouldReturnError {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        } else {
            let weatherResponse = MockWeatherData.getCurrentWeatherMockData()!
            return Just(weatherResponse)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchForcastWeather(for urlString: String) -> AnyPublisher<WeatherForcast, NetworkError> {
        if shouldReturnError {
            return Fail(error: NetworkError.decodingError)
                .eraseToAnyPublisher()
        } else {
            let forecastResponse = MockWeatherData.getMockForcasteWeatherData()!
            return Just(forecastResponse)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
    }
}

class MockWeatherData: NSObject {
    
    class func getCurrentWeatherMockData() -> WeatherResponse? {
        let data = loadtestDataFromFile(for: "currentWeather")
        return decodeJsonData(data: data, type: WeatherResponse.self) ?? nil
    }
    
    class func getMockForcasteWeatherData() -> WeatherForcast? {
        let data = loadtestDataFromFile(for: "forecastWeather")
        return decodeJsonData(data: data, type: WeatherForcast.self) ?? nil
    }

    
    class func loadtestDataFromFile(for fileName: String) -> Data {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                return Data()
        }
        return data
    }
    class func decodeJsonData<T:Decodable>(data: Data, type: T.Type) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        do {
            let result = try decoder.decode(T.self, from: data)
            return result
            
        } catch DecodingError.dataCorrupted(let context) {
            print(context)
            
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
        } catch {
            print("reason: Failed to convert data to JSON")
        }
        return nil
    }
}
