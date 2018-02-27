//
//  GiphySearchTableViewCell.swift
//  stchy
//
//  Created by Blake Barrett on 2/21/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

// TODO: Work on variable row-height TableViewCells.
// https://www.raywenderlich.com/129059/self-sizing-table-view-cells
// http://www.thomashanning.com/uitableview-automatic-row-height/
// https://stackoverflow.com/questions/30494702/dynamic-height-issue-for-uitableview-cells-swift

class GiphySearchTableViewCell: UITableViewCell {
    
    var playerLayer: AVPlayerLayer?
    
    var item: GiphyResult? {
        didSet(value) {
            guard let value = value else { return }
            render(value)
        }
    }
    var rendered = false
    var listenerOnlyAddedOnce = true
    
    override func layoutSubviews() {
        backgroundColor = UIColor.gray
        if !rendered {
            initAutoLayoutConstraints()
        }
        super.layoutSubviews()
        render(item)
    }
    
    private func initAutoLayoutConstraints() {
        
        NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant:0.0).isActive = true
        
        rendered = true
    }
    
    func render(_ item: GiphyResult?) {
        
        guard let item = item,
              let url = item.fullsizeMP4 else { return }
        
        if playerLayer != nil {
            playerLayer?.removeFromSuperlayer()
        }
        
        let player = AVPlayer(url: url)
        player.isMuted = false
        player.automaticallyWaitsToMinimizeStalling = true
        
        if listenerOnlyAddedOnce {
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: playerLayer?.player?.currentItem,
                                                   queue: .main) { [weak self] _ in
                                                    self?.playVideo()
            }
            listenerOnlyAddedOnce = false
        }
        
        playerLayer = AVPlayerLayer(player: player)
        guard let layer = playerLayer else { return }
        layer.frame = contentView.bounds
        layer.videoGravity = AVLayerVideoGravity.resizeAspect
        
        // add the layer to the container view
        contentView.layer.addSublayer(layer)
        
        playVideo()
    }
}

extension GiphySearchTableViewCell {
    
    func removePlayer() {
        playerLayer?.player = nil
        playerLayer?.sublayers?.forEach({ (layer) in
            layer.removeFromSuperlayer()
        })
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    func playVideo() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        playerLayer?.player?.seek(to: kCMTimeZero) { [weak self] _ in
            self?.playerLayer?.player?.play()
        }
    }
}
