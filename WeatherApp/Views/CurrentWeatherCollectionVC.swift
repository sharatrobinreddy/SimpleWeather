//
//  CurrentWeatherCollectionVC.swift
//  WeatherApp
//
//  Created by Sharat Guduru on 8/12/24.
//

import UIKit
import Combine

class CurrentWeatherCollectionVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var unitsControl: UISegmentedControl!
    @IBOutlet weak var citySearchBar: UISearchBar!
    
    var viewModel = CurrentWeatherViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        setupCollectionView()
        citySearchBar.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createCollectionViewLayout()
        
        collectionView.register(ThreeHourForcasteViewCell.self, forCellWithReuseIdentifier: ThreeHourForcasteViewCell.identifier)
        collectionView.register(CurrentWeatherViewCell.self, forCellWithReuseIdentifier: CurrentWeatherViewCell.identifier)
        collectionView.register(FiveDayForecastViewCell.self, forCellWithReuseIdentifier: FiveDayForecastViewCell.identifier)
    }
    
    private func bindViewModel() {
        viewModel.$forecastArray
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] errorMessage in
                if let message = errorMessage {
                    self?.showErrorAlert(message)
                }
            }
            .store(in: &cancellables)
    }
    
    private func showErrorAlert(_ message: String) {
        let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @IBAction func onUnitChanged(_ sender: UISegmentedControl) {
        let metric = sender.selectedSegmentIndex == 0
        viewModel.fetchWeatherData(metric: metric ? .metric : .imperial)
    }
}

// MARK: - UISearchBarDelegate
extension CurrentWeatherCollectionVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text, !city.isEmpty else { return }
        searchBar.resignFirstResponder()
        viewModel.fetchWeatherData(cityName: city)
        searchBar.text = nil
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension CurrentWeatherCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel.currentWeather != nil ? 1 : 0
        case 1: return viewModel.threeHourForecast.count
        case 2: return viewModel.fiveDayForecast.keys.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            return createCurrentWeatherCell(for: indexPath)
        case 1:
            return createThreeHourForecastCell(for: indexPath)
        case 2:
            return createFiveDayForecastCell(for: indexPath)
        default:
            return UICollectionViewCell()
        }
    }
    
    private func createCurrentWeatherCell(for indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrentWeatherViewCell.identifier, for: indexPath) as? CurrentWeatherViewCell else {
            return UICollectionViewCell()
        }
        if let weather = viewModel.currentWeather {
            cell.configure(with: weather.cityName, description: weather.weatherDesc, temperature: weather.temperature, highLow: "\(weather.high) \(weather.low)", icon: weather.iconImage)
        }
        cell.styleCell()
        return cell
    }
    
    private func createThreeHourForecastCell(for indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThreeHourForcasteViewCell.identifier, for: indexPath) as? ThreeHourForcasteViewCell else {
            return UICollectionViewCell()
        }
        let weather = viewModel.threeHourForecast[indexPath.item]
        cell.configure(hour: weather.hourLabel, temperature: weather.temperature, icon: weather.iconImage)
        cell.styleCell()
        return cell
    }
    
    private func createFiveDayForecastCell(for indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FiveDayForecastViewCell.identifier, for: indexPath) as? FiveDayForecastViewCell else {
            return UICollectionViewCell()
        }
        let weatherArray = viewModel.fiveDayForecast.sorted(by: { $0.key < $1.key })[indexPath.row].value
        if let weather = weatherArray.first {
            cell.configure(with: "\(weather.weekDay) \(weather.dayNumber)", temperature: weather.temperature, high: weather.high, low: weather.low, icon: weather.iconImage)
        }
        cell.styleCell()
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CurrentWeatherCollectionVC: UICollectionViewDelegateFlowLayout {
    
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (section, _) -> NSCollectionLayoutSection? in
            switch section {
            case 0:
                return self.createSingleItemSection()
            case 1:
                return self.createHorizontalScrollingSection()
            case 2:
                return self.createVerticalSection()
            default:
                return nil
            }
        }
    }
    
    private func createHorizontalScrollingSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/5),
                heightDimension: .fractionalHeight(1)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(140)
            ),
            repeatingSubitem: item,
            count: 5
        )
        group.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        return section
    }
    
    private func createSingleItemSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(300)
            ),
            repeatingSubitem: item,
            count: 1
        )
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        return section
    }
    
    private func createVerticalSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(120)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0)
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(120)
            ),
            repeatingSubitem: item,
            count: 1
        )
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        return section
    }
}

// MARK: - UICollectionViewCell Extension for Styling
private extension UICollectionViewCell {
    func styleCell() {
        self.backgroundColor = .quaternaryLabel
        self.layer.cornerRadius = 8
    }
}

