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
    
    var results = [GiphyResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        if results.count == 0 {
            presentSearch()
        }
    }
    
    private func presentSearch() {
        searchViewController = GiphySearchViewController() { [weak self] item in
            guard let item = item else { return }
            self?.results.append(item)
            print(String(describing: item.title))
        }
        guard let searchView = searchViewController else { return }
        present(searchView, animated: true)
    }
    
    @IBAction func onClick(_ sender: Any) {
        presentSearch()
    }
}
