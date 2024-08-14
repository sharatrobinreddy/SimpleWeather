//
//  CurrentWeatherViewController.swift
//  WeatherApp
//
//  Created by Sharat Guduru on 8/12/24.
//

import UIKit
import Combine
class CurrentWeatherViewController: UIViewController {
    @IBOutlet weak var unitsControl: UISegmentedControl!
    
    @IBOutlet weak var weatherTableView: UITableView!
    @IBOutlet weak var citySearchBar: UISearchBar!
    var viewModel = CurrentWeatherViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        intialSetup()
        bindViewModel()
    }
    
    func intialSetup() {
        weatherTableView.delegate = self
        weatherTableView.dataSource = self
        weatherTableView.estimatedRowHeight = 120
        weatherTableView.rowHeight = UITableView.automaticDimension
        citySearchBar.delegate = self
        weatherTableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: "WeatherTableViewCell")
    }
    
    private func bindViewModel() {
        viewModel.reloadTableViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.weatherTableView.reloadData()
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func OnUnitChanged(_ sender: Any) {
    }
    
}

extension CurrentWeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.weatherDatasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as? WeatherTableViewCell else {
            return UITableViewCell()
        }

        let weather = viewModel.weatherDatasource[indexPath.row]
        cell.configure(with: weather.cityName, description: weather.weatherDesc, temperature: weather.temperature, highLow: "\(weather.high) - \(weather.low)", icon: weather.iconImage)
        return UITableViewCell()

    }
}



extension CurrentWeatherViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text, !city.isEmpty else { return }
        searchBar.resignFirstResponder()
        viewModel.cityName = city
        viewModel.getLocation()
        searchBar.text = nil
    }
    
}




class ImageDownloader {
    
    static let shared = ImageDownloader()
    private let imageCache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func downloadImage(with urlString: String) -> AnyPublisher<UIImage?, Never> {
        // Check if the image is already in cache
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            return Just(cachedImage).eraseToAnyPublisher()
        }
        
        // Otherwise, download the image
        guard let url = URL(string: urlString) else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, response in
                return UIImage(data: data)
            }
            .catch { _ in
                Just(nil)
            }
            .handleEvents(receiveOutput: { [weak self] image in
                guard let self = self, let image = image else { return }
                self.imageCache.setObject(image, forKey: urlString as NSString)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
