//
//  NetworkService.swift
//  Gallery
//
//  Created by Николай Игнатов on 15.05.2023.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchTextFileContent(completion: @escaping (Result<String, Error>) -> Void)
    func downloadImage(from url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    
    private let fileURL = URL(string: "https://it-link.ru/test/images.txt")
    
    private func fetchData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NetworkError.invalidData))
            }
        }
        
        task.resume()
    }
    
    func fetchTextFileContent(completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let fileURL = fileURL else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        fetchData(from: fileURL) { result in
            switch result {
            case .success(let data):
                if let content = String(data: data, encoding: .utf8) {
                    completion(.success(content))
                } else {
                    completion(.failure(NetworkError.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func downloadImage(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        fetchData(from: url, completion: completion)
    }
}

enum NetworkError: Error {
    case invalidData
    case invalidURL
}
