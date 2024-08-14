//
//  CurrentWeatherViewCell.swift
//  WeatherApp
//
//  Created by Sharat Guduru on 8/13/24.
//

import UIKit
import Combine
class CurrentWeatherViewCell: UICollectionViewCell {
    
    static let identifier = "CurrentWeatherViewCell"

    // MARK: - UI Elements
    private let cityLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let highLowLabel = UILabel()
    private let weatherIcon = UIImageView()
    private var stackview: UIStackView!

    // MARK: - Combine Cancellable
    private var cancellable: AnyCancellable?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        cityLabel.font = UIFont.boldSystemFont(ofSize: 44)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        temperatureLabel.font = UIFont.boldSystemFont(ofSize: 44)
        highLowLabel.font = UIFont.systemFont(ofSize: 14)
        
        weatherIcon.contentMode = .scaleAspectFill

        stackview = createStackView(with: [weatherIcon, cityLabel, temperatureLabel, descriptionLabel], axis: .vertical, alignment: .center, distribution: .fillProportionally, spacing: 0)
        contentView.addSubview(stackview)
        stackview.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // stackview stack constraints
            stackview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // Weather icon constraints
            weatherIcon.widthAnchor.constraint(equalToConstant: 100),
            weatherIcon.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func createStackView(with arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        return stackView
    }
    
    // MARK: - Configuration
    func configure(with city: String, description: String, temperature: String, highLow: String, icon: String) {
        cityLabel.text = city
        descriptionLabel.text = description
        temperatureLabel.text = temperature
        highLowLabel.text = highLow
        
        // Cancel any existing download task before starting a new one
        cancellable?.cancel()
        cancellable = ImageDownloader.shared.downloadImage(with: icon)
            .sink { [weak self] image in
                self?.weatherIcon.image = image
            }
    }
    
    // MARK: - Reuse Preparation
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel() // Cancel the ongoing download task when the cell is reused
        weatherIcon.image = nil // Reset the image to avoid flickering
    }
}
