//
//  GiphySearchTableViewCell.swift
//  stchy
//
//  Created by Blake Barrett on 2/21/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit

class GiphySearchTableViewCell: UITableViewCell {
    
    var item: GiphyResult? {
        didSet(value) {
            guard let value = value else { return }
            render(value)
        }
    }
    var rendered = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        if !rendered {
            initAutoLayoutConstraints()
        }
        super.layoutSubviews()
    }
    
    private func initAutoLayoutConstraints() {
        
        guard let imageView = imageView else { return }
        
        NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant:0.0).isActive = true
        
        rendered = true
    }
    
    func render(_ item: GiphyResult) {
        
        guard let previewImageUrl = item.previewImage else { return }
        imageView?.loadImageFromUrl(url: previewImageUrl)
        imageView?.contentMode = .scaleAspectFit
        
        guard let aspectRatio = item.aspectRatio else { return }
        let height = frame.width / CGFloat(aspectRatio)
        imageView?.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: height)
    }
}

extension UIImageView {
    public func loadImageFromUrl(url: URL) {
        DispatchQueue.global().async {
            guard let imageData = try? Data.init(contentsOf: url),
                  let image = UIImage(data: imageData) else { return }
            DispatchQueue.main.async { [weak self] in
//                if let width = self?.frame.width,
//                   let height = image.cgImage?.height {
//                    let aspectRatio = width / CGFloat(height)
//                    self?.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width / aspectRatio))
//                }
                self?.image = image
                self?.contentMode = .scaleAspectFit
            }
        }
    }
}
