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

// TODO: Add fullscreen thumbnail view while the video is loading
// alternatively, add a full-size video preview that isn't a fullscreen stand alone ViewController

class DetailViewController: UIViewController {
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            guard let title = detail.title,
                  let url = detail.fullsizeMP4 else { return }
            self.title = title
            playVideo(url: url)
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

extension DetailViewController {
    
    func playVideo(url: URL) {
        // Create a new AVPlayerViewController and pass it a reference to the player.
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        
        // Modally present the player and call the player's play() method when complete.
        present(controller, animated: true) {
            controller.player?.play()
        }
    }
}
