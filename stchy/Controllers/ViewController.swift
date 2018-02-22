//
//  ViewController.swift
//  stchy
//
//  Created by Blake Barrett on 2/20/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var searchViewController: GiphySearchViewController?
    
    override func viewDidLoad() {
        searchViewController = GiphySearchViewController() { item in
            print(String(describing: item?.title))
        }
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func presentSearch() {
        guard let searchView = searchViewController else { return }
        present(searchView, animated: true)
    }
    
    @IBAction func onClick(_ sender: Any) {
        presentSearch()
    }
    
}

