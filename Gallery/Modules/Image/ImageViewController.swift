//
//  ImageViewController.swift
//  Gallery
//
//  Created by Николай Игнатов on 15.05.2023.
//

import UIKit

final class ImageViewController: UIViewController {
    
    private var isNavBarShowing = false
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentMode = .scaleAspectFit
        scrollView.backgroundColor = UIColor(named: "BackgroundColor")
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 6
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var pictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.pictureImageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupGesture()
    }
    
    private func setupView() {
        navigationController?.navigationBar.tintColor = UIColor(named: "TextColor")
        view.addSubview(scrollView)
        scrollView.addSubview(pictureImageView)
        scrollView.contentSize = pictureImageView.bounds.size
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pictureImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            pictureImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            pictureImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            pictureImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            pictureImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            pictureImageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])
    }
    
    private func setupGesture() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        singleTapGesture.numberOfTapsRequired = 1
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
        doubleTapGesture.numberOfTapsRequired = 2
        singleTapGesture.require(toFail: doubleTapGesture)
        
        scrollView.addGestureRecognizer(singleTapGesture)
        scrollView.addGestureRecognizer(doubleTapGesture)
    }
    
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = pictureImageView.bounds.size.height / scale
        zoomRect.size.width = pictureImageView.bounds.size.width / scale
        
        let newCenter = pictureImageView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
   
    @objc private func handleSingleTap(recognizer: UITapGestureRecognizer) {
        if isNavBarShowing {
            navigationController?.navigationBar.isHidden = true
            isNavBarShowing.toggle()
        } else {
            navigationController?.navigationBar.isHidden = false
            isNavBarShowing.toggle()
        }
    }
    
    @objc private func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            let zoomRect = zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: pictureImageView))
            scrollView.zoom(to: zoomRect, animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
}

extension ImageViewController: UIScrollViewDelegate {
     func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pictureImageView
    }
}
