//
//  DetailViewController.swift
//  stchy
//
//  Created by Blake Barrett on 2/26/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class DetailViewController: UIViewController {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        removePlayer()
        configureView()
        playerLayer?.frame =  CGRect(origin: .zero, size: size)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: GiphyResult? {
        didSet {
            configureView()
        }
    }
}

@objc extension DetailViewController {
    
    func configureView() {
        view.backgroundColor = UIColor.black
        // Update the user interface for the detail item.
        if let detail = detailItem {
            guard let title = detail.title,
                let url = detail.fullsizeMP4 else { return }
            self.title = title
            
            if playerLayer != nil {
                playerLayer?.removeFromSuperlayer()
            }
            
            player = AVPlayer(url: url)
            guard let player = player else { return }
            player.isMuted = false
            player.automaticallyWaitsToMinimizeStalling = true
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: self.player?.currentItem,
                                                   queue: .main) { [weak self] _ in
                                                    self?.playVideo()
            }
            
            playerLayer = AVPlayerLayer(player: player)
            guard let layer = playerLayer else { return }
            layer.frame = view.bounds
            layer.videoGravity = AVLayerVideoGravity.resizeAspect
            
            // add the layer to the container view
            view.layer.addSublayer(layer)
            
            playVideo()
        }
    }

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
        player?.seek(to: kCMTimeZero) { [weak self] _ in
            self?.player?.play()
        }
    }
}
