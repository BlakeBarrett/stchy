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
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            guard let title = detail.title,
                  let url = detail.fullsizeMP4 else { return }
            self.title = title
            
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            
            player = AVPlayer(url: url)
            guard let player = player else { return }
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.playerFinished),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: self.player?.currentItem)
            
            let layer: AVPlayerLayer = AVPlayerLayer(player: player)
            layer.frame = self.view.bounds
            layer.videoGravity = AVLayerVideoGravity.resizeAspect
            
            // add the layer to the container view
            self.view.layer.addSublayer(layer)
            
            playVideo()
        }
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
    
    @objc func playerFinished() {
        player?.seek(to: kCMTimeZero)
        playVideo()
    }
    
    func playVideo() {
        player?.play()
    }
}
