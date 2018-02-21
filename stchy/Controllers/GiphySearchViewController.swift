//
//  GiphySearchViewController.swift
//  stchy
//
//  Created by Blake Barrett on 2/20/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit

class GiphySearchViewController: UIViewController {
    
    private var results: [GiphyResult]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func doSearch(query: String) {
        GiphySearchAPI.search(query: query, completion: {[weak self] (searchResults) in
            self?.results = searchResults
        })
    }
}

extension GiphySearchViewController {
    func addSearchBar() {
        
    }
}

extension GiphySearchViewController {
    func addTableView() {
        
    }
}

extension GiphySearchViewController {
    
}
