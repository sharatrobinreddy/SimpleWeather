//
//  FiveDayForecastViewCell.swift
//  WeatherApp
//
//  Created by Sharat Guduru on 8/13/24.
//

import UIKit
import Combine

class FiveDayForecastViewCell: UICollectionViewCell {
    
    static let identifier = "FiveDayForecastViewCell"

    // MARK: - UI Elements
    private let dayLabel = UILabel()
    private let dayNumber = UILabel()
    private let temperatureLabel = UILabel()
    private let highLabel = UILabel()
    private let LowLabel = UILabel()
    private let weatherIcon = UIImageView()
    private var stackView: UIStackView!

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
        dayLabel.font = UIFont.boldSystemFont(ofSize: 16)
        temperatureLabel.font = UIFont.boldSystemFont(ofSize: 44)
        highLabel.font = UIFont.systemFont(ofSize: 18)
        LowLabel.font = UIFont.systemFont(ofSize: 18)

        weatherIcon.contentMode = .scaleAspectFit
        
        // Create and configure stack views
        stackView = createStackView(with: [dayLabel, weatherIcon, LowLabel, highLabel], axis: .horizontal, alignment: .center, distribution: .equalSpacing, spacing: 0)
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Horizontal stack constraints
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // Weather icon constraints
            weatherIcon.widthAnchor.constraint(equalToConstant: 64),
            weatherIcon.heightAnchor.constraint(equalToConstant: 64)
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
    func configure(with dayString: String, temperature: String, high: String, low: String, icon: String) {
        dayLabel.text = dayString
        highLabel.text = high
        temperatureLabel.text = temperature
        LowLabel.text = low
        
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
