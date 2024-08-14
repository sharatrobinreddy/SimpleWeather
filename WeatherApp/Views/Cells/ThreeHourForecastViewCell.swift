//
//  ThreeHourForecastViewCell.swift
//  WeatherApp
//
//  Created by Sharat Guduru on 8/13/24.
//

import UIKit
import Combine
class ThreeHourForcasteViewCell: UICollectionViewCell {
    static let identifier = "ThreeHourForcasteViewCell"
    
    // MARK: - UI Elements
    private let hourLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let weatherIcon = UIImageView()
    private var verticalStack: UIStackView!

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
        hourLabel.font = UIFont.boldSystemFont(ofSize: 14)
        temperatureLabel.font = UIFont.boldSystemFont(ofSize: 20)
        weatherIcon.contentMode = .scaleAspectFit
        
        // Create and configure stack views
        verticalStack = createStackView(with: [hourLabel, weatherIcon, temperatureLabel], axis: .vertical,alignment: .center, spacing: 5)
        
        contentView.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Horizontal stack constraints
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            // Weather icon constraints
            weatherIcon.widthAnchor.constraint(equalToConstant: 40),
            weatherIcon.heightAnchor.constraint(equalToConstant: 40)
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
    func configure(hour: String, temperature: String, icon: String) {
        hourLabel.text = hour
        temperatureLabel.text = temperature
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
