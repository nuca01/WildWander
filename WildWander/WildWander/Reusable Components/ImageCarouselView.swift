//
//  ImageCarouselView.swift
//  WildWander
//
//  Created by nuca on 08.07.24.
//

import UIKit

final class ImageCarouselView: UIView {
    //MARK: - Properties
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: bounds)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        return scrollView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: frame.height - 50, width: frame.width, height: 50))
        pageControl.numberOfPages = imageURLs.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        
        return pageControl
    }()
    
    var imageURLs: [URL?] {
        didSet {
            setupImages()
        }
    }
    
    //MARK: - Initializers
    init(frame: CGRect, imageURLs: [URL?]) {
        self.imageURLs = imageURLs
        super.init(frame: frame)
        setupScrollView()
        setupPageControl()
        setupImages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.frame = bounds
    }
    
    private func setupPageControl() {
        addSubview(pageControl)
        pageControl.frame = CGRect(x: 0, y: frame.height - 50, width: frame.width, height: 50)
    }
    
    private func setupImages() {
        scrollView.subviews.forEach {
            if $0 != pageControl {
                $0.removeFromSuperview()
            }
        }
        
        for (index, url) in imageURLs.enumerated() {
            let imageView = UIImageView()
            if let url {
                imageView.load(url: url)
            }
            imageView.contentMode = .scaleToFill
            imageView.frame = CGRect(x: CGFloat(index) * frame.width, y: 0, width: frame.width, height: frame.height)
            scrollView.addSubview(imageView)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.scrollView.contentSize = CGSize(width: frame.width * CGFloat(imageURLs.count), height: frame.height)
            self.pageControl.numberOfPages = imageURLs.count
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        pageControl.frame = CGRect(x: 0, y: bounds.height - 50, width: bounds.width, height: 50)
    }
    
    @objc private func pageControlValueChanged(_ sender: UIPageControl) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if sender.currentPage >= sender.numberOfPages
            {
                sender.currentPage -= 1
                return
            }
            
            if sender.currentPage < 0
            {
                sender.currentPage += 1
                return
            }
            self.scrollView.contentOffset.x = frame.width * CGFloat(integerLiteral: sender.currentPage)
        }
    }
}

//MARK: - UIScrollViewDelegate
extension ImageCarouselView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let pageIndex = Int(round(scrollView.contentOffset.x / frame.width))
            if pageIndex < imageURLs.count && pageIndex >= 0 {
                pageControl.currentPage = pageIndex
            }
        }
    }
}
