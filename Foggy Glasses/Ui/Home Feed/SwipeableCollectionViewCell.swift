//
//  SwipeableCollectionViewCell.swift
//  SwipeableCollectionViewCell
//
//  Created by Amer Hukic on 23/08/2018.
//  Copyright © 2018 Amer Hukic. All rights reserved.
//
import UIKit

protocol SwipeableCollectionViewCellDelegate: class {
    func hiddenContainerViewTapped(inCell cell: UICollectionViewCell)
}

class SwipeableCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    let visibleContainerView = UIView()
    let hiddenContainerView = UIView()
    
    weak var delegate: SwipeableCollectionViewCellDelegate?
    
    // MARK: Initializers
    
    override func prepareForReuse() {
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(visibleContainerView)
        stackView.addArrangedSubview(hiddenContainerView)
        
        addSubview(scrollView)
        scrollView.pinEdgesToSuperView()
        scrollView.addSubview(stackView)
        stackView.pinEdgesToSuperView()
        stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 2).isActive = true
    }
    
    private func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hiddenContainerViewTapped))
        hiddenContainerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func hiddenContainerViewTapped() {
        delegate?.hiddenContainerViewTapped(inCell: self)
    }
    
}
