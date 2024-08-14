//
//  CurrentWeatherViewModel.swift
//  WeatherApp
//
//  Created by Sharat Guduru on 8/12/24.
//


import Foundation
import CoreLocation
import Combine

class CurrentWeatherViewModel: ObservableObject {
    
    enum TempMetric: String {
        case metric = "metric"
        case imperial = "imperial"
    }
    
    private var locationManager: LocationManager?
    private var networkManager: WeatherServiceAPIProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var errorMessage: String?
    @Published var forecastArray: [WeatherDataObject] = []
    
    var currentWeather: WeatherDataObject?
    var defaultMetric: TempMetric = .metric
    var reloadTableViewClosure: (() -> Void)?
    
    init(api: WeatherServiceAPIProtocol = NetworkManager(weatherAPI: WeatherAPI())) {
        self.networkManager = api
        setupLocationManager()
        fetchCurrentLocationWeather()
    }
    
    private func setupLocationManager() {
        locationManager = LocationManager()
        locationManager?.onLocationUpdate = { [weak self] location in
            self?.fetchWeatherData(for: location.coordinate)
        }
    }
    
    private func fetchCurrentLocationWeather() {
        if let lastSearchedCityName = UserDefaults.standard.string(forKey: Constants.lastSearched) {
            fetchWeatherData(cityName: lastSearchedCityName)
        } else {
            locationManager?.requestLocation()
            
        }
    }
    
    func fetchWeatherData(cityName: String? = nil, metric: TempMetric = .metric) {
        guard let cityName = cityName ?? UserDefaults.standard.string(forKey: Constants.lastSearched) else { return }
        self.defaultMetric = metric
        CLGeocoder().geocodeAddressString(cityName) { [weak self] (placemarks, error) in
            if let location = placemarks?.first?.location {
                self?.fetchWeatherData(for: location.coordinate)
            }
        }
    }
    
    private func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
        let currentWeatherURL = "\(Constants.API.url)/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(Constants.API.keyAPI)&units=\(defaultMetric.rawValue)"
        let forecastURL = "\(Constants.API.url)/forecast?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(Constants.API.keyAPI)&units=\(defaultMetric.rawValue)"
        
        let currentWeatherPublisher: AnyPublisher<WeatherResponse, NetworkError> = networkManager.fetchCurrentWeather(for: currentWeatherURL)
        let forecastPublisher: AnyPublisher<WeatherForcast, NetworkError> = networkManager.fetchForcastWeather(for: forecastURL)
        
        Publishers.Zip(currentWeatherPublisher, forecastPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("Fetch successful")
                case .failure(let error):
                    self?.errorMessage = self?.handleError(error)
                }
            }, receiveValue: { [weak self] currentWeather, forecast in
                self?.updateDataSource(current: currentWeather, forecast: forecast)
            })
            .store(in: &cancellables)
    }
    
    private func updateDataSource(current: WeatherResponse, forecast: WeatherForcast) {
        self.currentWeather = WeatherDataObject(current)
        self.forecastArray = forecast.list.map { WeatherDataObject($0) }
        UserDefaults.standard.setValue(currentWeather?.cityName, forKey: Constants.lastSearched)
    }
    
    private func handleError(_ error: NetworkError) -> String {
        switch error {
        case .invalidURL:
            return "Invalid URL"
        case .decodingError:
            return "Failed to decode data"
        case .other(let err):
            return err.localizedDescription
            
        }
    }
    
    var threeHourForecast: [WeatherDataObject] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        return forecastArray.filter { $0.weather.dt >= startOfToday && $0.weather.dt < endOfToday }
    }
    
    var fiveDayForecast: [Date: [WeatherDataObject]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var groupedData = [Date: [WeatherDataObject]]()
        
        forecastArray.forEach { item in
            if let date = dateFormatter.date(from: item.dateText) {
                groupedData[date, default: []].append(item)
            }
        }
        
        let sortedWeatherData = groupedData.sorted { $0.key < $1.key }
        let droppedFirstItemArray = Array(sortedWeatherData.dropFirst())
        
        // Convert the sorted array back to a dictionary
        return  Dictionary(uniqueKeysWithValues: droppedFirstItemArray)
    }
}
