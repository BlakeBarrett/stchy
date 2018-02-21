//
//  GiphyResult.swift
//  stchy
//
//  Created by Blake Barrett on 2/20/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation

public class GiphyResult {
    
    typealias JSON = [String: Any]
    
    private var jsonResult: JSON
    
    public var id: String?
    public var title: String?
    public var previewImage: URL?
    public var previewMP4: URL?
    public var fullsizeMP4: URL?
    
    init(json: JSON) {
        jsonResult = json
        id = json["id"] as? String
        title = json["title"] as? String
        guard let images = json["images"] as? JSON else { return }
        if let still = images["480w_still"] as? JSON,
           let previewImageUrlString = still["url"] as? String {
            previewImage = URL(string: previewImageUrlString)
        }
        if let preview = images["preview"] as? JSON,
           let previewMP4UrlString = preview["mp4"] as? String {
            previewMP4 = URL(string: previewMP4UrlString)
        }
        if let fullsize = images["original"] as? JSON,
           let fullsizeMP4UrlString = fullsize["mp4"] as? String {
            fullsizeMP4 = URL(string: fullsizeMP4UrlString)
        }
    }
}
