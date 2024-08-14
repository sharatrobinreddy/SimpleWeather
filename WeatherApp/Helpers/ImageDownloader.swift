//
//  ImageDownloader.swift
//  WeatherApp
//
//  Created by Sharat Guduru on 8/13/24.
//

import UIKit
import Combine
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
