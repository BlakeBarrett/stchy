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
        super.layoutSubviews()
    }
    
    func render(_ item: GiphyResult) {
        
        guard let previewImageUrl = item.previewImage else { return }
        let imageView = UIImageView(frame: self.frame)
        imageView.loadImageFromUrl(url: previewImageUrl)
        contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        contentView.addSubview(imageView)
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
