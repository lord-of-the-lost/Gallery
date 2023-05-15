//
//  ImageCacheService.swift
//  Gallery
//
//  Created by Николай Игнатов on 15.05.2023.
//

import UIKit

protocol ImageCacheServiceProtocol {
    func saveImageToCache(image: UIImage, fileName: String)
    func loadImageFromCache(fileName: String) -> UIImage?
}

final class ImageCacheService: ImageCacheServiceProtocol {
    private let fileManager: FileManager
    private let cacheDirectory: URL
    
    init?() {
        fileManager = FileManager.default
        
        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        self.cacheDirectory = cacheDirectory.appendingPathComponent("Images")
        
        if !fileManager.fileExists(atPath: self.cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating Images directory: \(error)")
                return nil
            }
        }
    }
    
    func saveImageToCache(image: UIImage, fileName: String) {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Ошибка сохранения изображения в кэш: \(error)")
        }
    }
    
    func loadImageFromCache(fileName: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
