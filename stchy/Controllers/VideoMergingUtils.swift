//
//  VideoMergingUtils.swift
//  stchy
//
//  Created by Blake Barrett on 2/22/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation
import MobileCoreServices
import AVFoundation
import MediaPlayer

protocol Video {
    var duration: CMTime { get set }
    var muted: Bool { get set }
    var asset: AVAsset { get }
}

class VideoMergingUtils {
    
    // MARK: AVFoundation Video Manipulation Code
    static func append(_ assets: [Video], andExportTo outputUrl: URL, with backgroundAudio: MPMediaItem?) -> Bool {
        let mixComposition = AVMutableComposition()
        
        let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        //        var maxWidth: CGFloat = 0;
        //        var maxHeight: CGFloat = 0;
        //
        // run through all the assets selected
        assets.reversed().forEach {(video) in
            
            let timeRange = CMTimeRangeMake(kCMTimeZero, video.duration)
            
            // add all video tracks in asset
            let videoMediaTracks = video.asset.tracks(withMediaType: .video)
            videoMediaTracks.forEach{ (videoMediaTrack) in
                
                //                maxWidth = max(videoMediaTrack.naturalSize.width, maxWidth)
                //                maxHeight = max(videoMediaTrack.naturalSize.height, maxHeight)
                if let videoTrack = videoTrack {
                    try? videoTrack.insertTimeRange(timeRange, of: videoMediaTrack, at: kCMTimeZero)
                }
            }
            
            if video.muted {
                return
            }
            
            // add all audio tracks in asset
            let audioMediaTracks = video.asset.tracks(withMediaType: .audio)
            audioMediaTracks.forEach {(audioMediaTrack) in
                if let audioTrack = audioTrack {
                    try? audioTrack.insertTimeRange(timeRange, of: audioMediaTrack, at: kCMTimeZero)
                }
            }
        }
        
        // TODO: check this shit out for video rotation.
        // http://stackoverflow.com/questions/12136841/avmutablevideocomposition-rotated-video-captured-in-portrait-mode
        // http://stackoverflow.com/questions/27627610/video-not-rotating-using-avmutablevideocompositionlayerinstruction
        // And where would we be w/o Ray Wenderlich?
        // https://www.raywenderlich.com/13418/how-to-play-record-edit-videos-in-ios
        
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return false }
        exporter.outputURL = outputUrl
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.exportAsynchronously(completionHandler: {
            switch exporter.status {
            case .completed:
                // we can be confident that there is a URL because
                // we got this far. Otherwise it would've failed.
                let url = exporter.outputURL!
                print("MrgrViewController.exportVideo SUCCESS!")
                if exporter.error != nil {
                    print("MrgrViewController.exportVideo Error: \(String(describing: exporter.error))")
                    print("MrgrViewController.exportVideo Description: \(exporter.description)")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "videoExportDone"), object: exporter.error)
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "videoExportDone"), object: url)
                }
                
                break
                
            case .exporting:
                let progress = exporter.progress
                print("MrgrViewController.exportVideo \(progress)")
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "videoExportProgress"), object: progress)
                break
                
            case .failed:
                print("MrgrViewController.exportVideo Error: \(String(describing: exporter.error))")
                print("MrgrViewController.exportVideo Description: \(exporter.description)")
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "videoExportDone"), object: exporter)
                break
                
            default: break
            }
        })
        return true
    }
}
