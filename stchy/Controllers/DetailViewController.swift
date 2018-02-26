//
//  DetailViewController.swift
//  stchy
//
//  Created by Blake Barrett on 2/26/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            
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
