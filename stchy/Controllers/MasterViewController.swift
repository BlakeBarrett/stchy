//
//  MasterViewController.swift
//  stchy
//
//  Created by Blake Barrett on 2/26/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit
import AVFoundation
import BBMultimediaUtils

// TODO: Add "processing" modal
//  Update the TableViewCell to use `GiphySearchTableViewCell`s.

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var searchViewController: GiphySearchViewController? = nil
    var results = [GiphyResult]()
    
    var tempVideoPath: URL? = nil
    private var exportInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(GiphySearchTableViewCell.classForCoder().class(), forCellReuseIdentifier: GiphySearchViewController.poweredByGiphy)
        tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = view.frame.width / (16/9)

        initNavGoodies()
        initAddButton()
        initExportButton()
        initNotificationListeners()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        if results.count == 0 {
            presentSearch()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func insertNewObject(_ sender: Any) {
        presentSearch()
    }
    
    func presentSearch() {
        searchViewController = GiphySearchViewController() { [weak self] item in
            self?.onAddItem(value: item)
        }
        guard let searchView = searchViewController else { return }
        present(searchView, animated: true)
    }
    
    func onAddItem(value: GiphyResult?) {
        guard let item = value else { return }
        results.append(item)
        let indexPath = IndexPath(row: results.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let item = results[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = item
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

extension MasterViewController {

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GiphySearchViewController.poweredByGiphy, for: indexPath) as? GiphySearchTableViewCell else { return UITableViewCell() }
        let index = indexPath.row
        let item = results[index] as GiphyResult
        cell.item = item
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            results.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        default: break
        }
    }
}

extension MasterViewController {
    @objc func export() {
        guard exportInProgress == false else { return }
        let outputUrl = getPathForTempFileNamed(named: "temp.mov")
        let videos = results.map { value -> Video in
            return VideoResult(value: value)
        }
        exportInProgress = true
        let _ = BBVideoUtils.merge(videos, andExportTo: outputUrl)
    }
}

extension MasterViewController {
    
    func initNavGoodies() {
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.title = "stchy"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func initAddButton() {
        // Configure the "+" button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    func initExportButton() {
        // Add Export button
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let exportButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(export))
        guard let parentView = super.parent?.view else { return }
        let h: CGFloat = 44.0 // I HATE magic numbers, but this is what InterfaceBuilder says the natural height of this control is.
        let y: CGFloat = parentView.bounds.height - h
        let toolBarFrame = CGRect(origin: CGPoint(x: 0, y: y), size: CGSize(width: self.view.frame.width, height: h))
        let toolBar = UIToolbar(frame: toolBarFrame)
        toolBar.setItems([spacer, exportButton], animated: true)
        toolBar.alpha = 1.0
        // Add the toolBar above the TableView
        parentView.addSubview(toolBar)
    }
    
    func initNotificationListeners() {
        self.tempVideoPath = getPathForTempFileNamed(named: "temp.mov")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "videoExportDone"),
                                               object: nil,
                                               queue: .main) {message in
            if let url = message.object as? URL {
                //Export:
                let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    let nav = UINavigationController(rootViewController: activity)
                    nav.modalPresentationStyle = .popover
                    
                    let popover = nav.popoverPresentationController as UIPopoverPresentationController!
                    popover?.barButtonItem = self.navigationItem.rightBarButtonItem
                    
                    self.present(nav, animated: true, completion: nil)
                } else {
                    self.present(activity, animated: true, completion: nil)
                }
                self.exportInProgress = false
            }
        }
    }

    func getPathStringForFile(named filename: String) -> String {
        return NSTemporaryDirectory() + filename
    }
    
    func getPathForTempFileNamed(named filename: String) -> URL {
        let outputPath = getPathStringForFile(named: filename)
        let outputUrl = URL(fileURLWithPath: outputPath)
        removeTempFileAtPath(outputPath)
        return outputUrl
    }

    func removeTempFileAtPath(_ path: String) {
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: path)) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch _ {
            }
        }
    }
}

class VideoResult: Video {
    
    var asset: AVAsset?
    var videoUrl: URL?
    var thumbnail: UIImage?
    var duration: CMTime? {
        get {
            return self.asset?.duration
        }
        set(value) { }
    }
    var muted = false
    
    init(value: GiphyResult) {
        if let assetUrl = value.fullsizeMP4 {
            asset = AVAsset(url: assetUrl)
            videoUrl = assetUrl
        } else {
            // This is the "this doesn't work, leave me alone" path.
            asset = AVAsset(url: URL(fileURLWithPath: ""))
            videoUrl = URL(fileURLWithPath: "")
        }
        
        if let imageUrl = value.previewImage {
            BBImageUtils.loadImage(contentsOf: imageUrl) { image in
                self.thumbnail = image
            }
        }
    }
}
