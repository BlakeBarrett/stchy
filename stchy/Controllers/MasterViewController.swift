//
//  MasterViewController.swift
//  stchy
//
//  Created by Blake Barrett on 2/26/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit
import AVFoundation

// TODO: Add "export" button,
//  Run through all results,
//  download all MP4 assets locally to a temp dir,
//  use VideoMergingUtils to merge all the videos together,
//  wire up "export" feature (see MRGR).

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var searchViewController: GiphySearchViewController? = nil
    var results = [GiphyResult]()
    
    var tempVideoPath: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        _ = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(export))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        navigationItem.title = "stchy"
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let index = indexPath.row
        let title = (results[index] as GiphyResult).title
        cell.textLabel!.text = title
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
        let outputUrl = getPathForTempFileNamed(named: "temp.mov")
        let videos = results.map { value -> Video in
            return VideoResult(value: value)
        }
        let _ = VideoMergingUtils.append(videos, andExportTo: outputUrl, with: nil)
    }
}

extension MasterViewController {
    
    func initNotificationListeners() {
        self.tempVideoPath = getPathForTempFileNamed(named: "temp.mov")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "videoExportDone"), object: nil, queue: OperationQueue.main) {message in
            if let url = message.object as? URL {
//                //Save:
//                let filename = self.getPathStringForFile(named: "temp.mov")
//                UISaveVideoAtPathToSavedPhotosAlbum(filename, nil, nil, nil);
//
//                //Export:
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
    var duration: CMTime {
        get {
            return self.asset.duration
        }
        set(value) { }
    }
    var muted = false
    var asset: AVAsset
    
    init(value: GiphyResult) {
        if let assetUrl = value.fullsizeMP4 {
            self.asset = AVAsset(url: assetUrl)
        } else {
            // This is the "this doesn't work, leave me alone" path.
            asset = AVAsset(url: URL(fileURLWithPath: ""))
        }
    }
}
