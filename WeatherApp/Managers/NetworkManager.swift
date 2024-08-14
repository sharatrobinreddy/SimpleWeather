//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Sharat Guduru on 8/12/24.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case other(Error)
}
protocol NetworkManagerProtocol {
    func fetchWeather<T: Decodable>(url: String, type: T.Type) -> AnyPublisher<T, NetworkError>
}
protocol WeatherServiceAPIProtocol {
    func fetchCurrentWeather(for urlString: String) -> AnyPublisher<WeatherResponse, NetworkError>
    func fetchForcastWeather(for urlString: String) -> AnyPublisher<WeatherForcast, NetworkError>

}


class WeatherAPI: NetworkManagerProtocol {
    private let urlSession: URLSession
    private let decoder: JSONDecoder

    init(urlSession: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .secondsSince1970
    }

    func fetchWeather<T: Decodable>(url: String, type: T.Type) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: url) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        return urlSession.dataTaskPublisher(for: url)
            .tryMap { (data: Data, response: URLResponse) in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                if error is URLError {
                    return .invalidURL
                } else if error is DecodingError {
                    return .decodingError
                } else {
                    return .other(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

class NetworkManager: WeatherServiceAPIProtocol {
    private let weatherAPI: NetworkManagerProtocol

    init(weatherAPI: NetworkManagerProtocol) {
        self.weatherAPI = weatherAPI
    }

    func fetchCurrentWeather(for urlString: String) -> AnyPublisher<WeatherResponse, NetworkError> {
        return weatherAPI.fetchWeather(url: urlString, type: WeatherResponse.self)
    }

    func fetchForcastWeather(for urlString: String) -> AnyPublisher<WeatherForcast, NetworkError> {
        return weatherAPI.fetchWeather(url: urlString, type: WeatherForcast.self)
    }
}

