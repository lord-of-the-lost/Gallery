//
//  UIImage+Extension.swift
//  Gallery
//
//  Created by Николай Игнатов on 15.05.2023.
//

import UIKit

extension UIImage {
    func compressToPreview() -> UIImage? {
        let previewSize = CGSize(width: 50, height: 50)
        
        UIGraphicsBeginImageContextWithOptions(previewSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        self.draw(in: CGRect(origin: .zero, size: previewSize))
        
        guard let compressedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        return compressedImage
    }
}

