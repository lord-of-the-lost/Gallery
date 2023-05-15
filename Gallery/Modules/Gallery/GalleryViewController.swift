//
//  GalleryViewController.swift
//  Gallery
//
//  Created by Николай Игнатов on 13.05.2023.
//

import UIKit

final class GalleryViewController: UIViewController {
    
    private var imageData = [UIImage(systemName: "01.square"), UIImage(systemName: "02.square"), UIImage(systemName: "03.square"), UIImage(systemName: "04.square"), UIImage(systemName: "05.square"), UIImage(systemName: "06.square"), UIImage(systemName: "07.square"), UIImage(systemName: "08.square"), UIImage(systemName: "09.square")]
    
    private lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .gray
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImagePreviewCell.self, forCellWithReuseIdentifier: "imageCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
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
        imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImagePreviewCell else { return UICollectionViewCell() }
        
        cell.backgroundColor = .blue
        
//        if let image = imageData[indexPath.row] {
//            cell.configure(with: image)
//        }
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
        var widthAndHeight = collectionView.frame.width / 4 - 1
        
        if UIDevice.current.orientation.isLandscape {
            widthAndHeight = collectionView.frame.width / 6 - 1
        }
        
        return CGSize(width: widthAndHeight, height: widthAndHeight)
    }
}
