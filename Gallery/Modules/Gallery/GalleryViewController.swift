//
//  GalleryViewController.swift
//  Gallery
//
//  Created by Николай Игнатов on 13.05.2023.
//

import UIKit

final class GalleryViewController: UIViewController {
    
    private var imagesArray: [String] = []
    
    private var network: NetworkServiceProtocol
    
    private var cacheService: ImageCacheServiceProtocol
    
    private lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(named: "BackgroundColor")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImagePreviewCell.self, forCellWithReuseIdentifier: "imageCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        galleryCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        fetchData()
    }
    
    init() {
        guard let cacheService = ImageCacheService() else {
            fatalError("Unable to create ImageCacheService")
        }
        self.network = NetworkService()
        self.cacheService = cacheService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchData() {
        network.fetchTextFileContent { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let content):
                let imageURLs = content.components(separatedBy: .newlines)
                
                for imageURLString in imageURLs {
                    if let imageURL = URL(string: imageURLString) {
                        self.downloadAndCacheImage(from: imageURL)
                    }
                }
                
            case .failure(let error):
                print("Ошибка загрузки текстового файла: \(error)")
            }
        }
    }
    
    private func downloadAndCacheImage(from url: URL) {
        network.downloadImage(from: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let imageData):
                if let image = UIImage(data: imageData) {
                    let originalFileName = "\(UUID().uuidString).jpg"
                    self.cacheService.saveImageToCache(image: image, fileName: originalFileName)
                    self.imagesArray.append(originalFileName)
                    
                    if let previewImage = image.compressToPreview() {
                        let previewFileName = "\(UUID().uuidString).jpg"
                        self.cacheService.saveImageToCache(image: previewImage, fileName: previewFileName)
                    }
                    
                    DispatchQueue.main.async {
                        self.galleryCollectionView.reloadData()
                    }
                }
                
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error)")
            }
        }
    }
    
    private func setupView() {
        title = "Gallery"
        view.backgroundColor = UIColor(named: "BackgroundColor")
        view.addSubview(galleryCollectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            galleryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            galleryCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            galleryCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            galleryCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImagePreviewCell else {
            return UICollectionViewCell()
        }
        
        let fileName = imagesArray[indexPath.row]
        if let image = cacheService.loadImageFromCache(fileName: fileName) {
            cell.configure(with: image)
        }
        
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fileName = imagesArray[indexPath.row]
        if let image = cacheService.loadImageFromCache(fileName: fileName) {
            let imageViewController = ImageViewController(image: image)
            navigationController?.pushViewController(imageViewController, animated: true)
        }
    }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var widthAndHeight = collectionView.frame.width / 4 - 5
        
        if UIDevice.current.orientation.isLandscape {
            widthAndHeight = collectionView.frame.width / 6 - 7
        }
        
        return CGSize(width: widthAndHeight, height: widthAndHeight)
    }
}
