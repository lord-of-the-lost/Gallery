//
//  GalleryViewController.swift
//  Gallery
//
//  Created by Николай Игнатов on 13.05.2023.
//

import UIKit

final class GalleryViewController: UIViewController {
    
    private var imagesArray: [UIImage] = []
    
    private var network: NetworkServiceProtocol
    
    private lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .gray
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
        self.network = NetworkService()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchData() {
        network.fetchTextFileContent(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let content):
                let imageURLs = content.components(separatedBy: .newlines)
                
                for imageURLString in imageURLs {
                    if let imageURL = URL(string: imageURLString) {
                        self.network.downloadImage(from: imageURL) { result in
                            switch result {
                            case .success(let imageData):
                                if let image = UIImage(data: imageData) {
                                    DispatchQueue.main.async {
                                        self.imagesArray.append(image)
                                        self.galleryCollectionView.reloadData()
                                    }
                                }
                            case .failure(let error):
                                print("Ошибка загрузки изображения: \(error)")
                            }
                        }
                    }
                }
                
            case .failure(let error):
                print("Ошибка загрузки текстового файла: \(error)")
            }
        })
    }
    
    
    private func setupView() {
        title = "Gallery"
        view.backgroundColor = .white
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImagePreviewCell else { return UICollectionViewCell() }
        
        let image = imagesArray[indexPath.row]
        cell.configure(with: image)
        return cell
    }
    
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(ImageViewController(), animated: true)
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
