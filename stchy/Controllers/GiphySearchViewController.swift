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
    
    private let poweredByGiphy = "Powered By GIPHY"
    private var results: [GiphyResult]?
    private let searchBarTop: CGFloat = 16
    private let searchBarHeight: CGFloat = 56
    
    private var searchInProgress = false
    
    var searchBar: UISearchBar!
    var tableView: UITableView!
    
    var onItemSelected: ((GiphyResult?) -> ())?
    
    init?(onItemSelected: (@escaping (GiphyResult?)->())) {
        self.onItemSelected = onItemSelected
        super.init(coder: NSCoder.empty())
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSearchBar()
        addTableView()
    }
    
    func doSearch(query: String?) {
        guard !searchInProgress,
              let query = query else { return }
        GiphySearchAPI.search(query: query, completion: {[weak self] (searchResults) in
            self?.results = searchResults
            self?.searchInProgress = false
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
    }
    
    func onResultSelected(result: GiphyResult?) {
        guard let result = result else { return }
        onItemSelected?(result)
    }
}

extension GiphySearchViewController {
    func addSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x: 0, y: searchBarTop, width: view.frame.width, height: searchBarHeight))
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.placeholder = poweredByGiphy // As per our section 5A of Giphy's terms of service, this is required.
        searchBar.delegate = self
        view.addSubview(searchBar)
    }
}

extension GiphySearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: {
            self.onItemSelected?(nil)
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doSearch(query: searchBar.text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch(query: searchText)
    }
}

extension GiphySearchViewController {
    func addTableView() {
        let y = view.safeAreaInsets.top + searchBarTop + searchBarHeight
        let height = view.frame.height - y
        
        let tableFrame = CGRect(x: 0, y: y, width: view.frame.width, height: height)
        tableView = UITableView(frame: tableFrame)
        tableView.register(GiphySearchTableViewCell.classForCoder().class(), forCellReuseIdentifier: poweredByGiphy)
        tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = view.frame.width / (16/9)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
}

extension GiphySearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func itemAt(_ indexPath: IndexPath) -> GiphyResult? {
        guard let results = results else { return nil }
        let size = results.count - 1
        let index = min(indexPath.row, size)
        return results[index]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onResultSelected(result: itemAt(indexPath))
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: poweredByGiphy, for: indexPath) as? GiphySearchTableViewCell {
            cell.item = itemAt(indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

fileprivate extension NSCoder {
    class func empty() -> NSCoder {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.finishEncoding()
        return NSKeyedUnarchiver(forReadingWith: data as Data)
    }
}
