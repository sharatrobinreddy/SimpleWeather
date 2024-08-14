//
//  CurrentWeatherViewModelTests.swift
//  WeatherAppTests
//
//  Created by Sharat Guduru on 8/13/24.
//

import XCTest
import Combine
@testable import WeatherApp
final class CurrentWeatherViewModelTests: XCTestCase {
    
    var viewModel: CurrentWeatherViewModel!
    var mockWeatherService: MockWeatherService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockWeatherService = MockWeatherService()
        viewModel = CurrentWeatherViewModel(api: mockWeatherService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockWeatherService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchWeatherSuccess() {
        viewModel.fetchWeatherData(cityName: "Austin")
        
        // Given
        let expectedCityName = "Austin"
        let expectation = self.expectation(description: "Weather data fetched")

        // When
        viewModel.fetchWeatherData(cityName: expectedCityName)
        viewModel.$forecastArray
            .sink { weatherDatasource in
                if !weatherDatasource.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 5, handler: nil)
        // Then
        XCTAssertEqual(viewModel.currentWeather?.temperature, "37°")
        XCTAssertEqual(viewModel.currentWeather?.cityName, "Austin")
        XCTAssertEqual(viewModel.currentWeather?.weatherDesc, "Clear")

    }
    
    func testFetchWeatherFailure() {

        // Given
        let expectedCityName = "Austin"
        mockWeatherService.shouldReturnError = true


        // When
        viewModel.fetchWeatherData(cityName: expectedCityName)

        // Then
        XCTAssertNil(viewModel.currentWeather)
        XCTAssertNotNil(viewModel.forecastArray)
    }
    
    func testThreeHourForecast() {
        // Given
        let forecastData = MockWeatherData.getMockForcasteWeatherData()?.list.map { WeatherDataObject($0) }
        viewModel.forecastArray = forecastData ?? []

        // When
        let threeHourForecast = viewModel.threeHourForecast
        
        // Then
        XCTAssertFalse(threeHourForecast.isEmpty)
    }
    
    func testFiveDayForecast() {
        // Given
        let forecastData = MockWeatherData.getMockForcasteWeatherData()?.list.map { WeatherDataObject($0) }
        viewModel.forecastArray = forecastData ?? []
        
        // When
        let fiveDayForecast = viewModel.fiveDayForecast
        
        // Then
        XCTAssertFalse(fiveDayForecast.isEmpty)
        XCTAssertEqual(fiveDayForecast.keys.count, 4)
    }
}
