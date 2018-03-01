//
//  BBVideoUtils.swift
//  BBVideoUtils
//
//  Created by Blake Barrett on 2/28/18.
//

import Foundation
import AVFoundation
import MediaPlayer

public protocol Video {
    var videoUrl: URL? { get set }
    var asset: AVAsset? { get set }
    var duration: CMTime? { get set }
    var thumbnail: UIImage?  { get set }
    var muted: Bool { get set }
}

public class BBVideoUtils {
    
    public static let exportCompleteNotification = Notification.Name(rawValue: "videoExportComplete")
    public static let exportProgressNotification = Notification.Name(rawValue: "videoExportProgress")
    
    // MARK: AVFoundation Video Manipulation Code
    
    public static func merge(_ assets: [Video], andExportTo outputUrl: URL, with backgroundAudio: MPMediaItem? = nil) -> Bool {
        let mixComposition = AVMutableComposition()
        
        let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        //        var maxWidth: CGFloat = 0;
        //        var maxHeight: CGFloat = 0;
        //
        // run through all the assets selected
        assets.reversed().forEach {(video) in
            
            guard let asset = video.asset,
                  let duration = video.duration else { return }
            
            let timeRange = CMTimeRangeMake(kCMTimeZero, duration)
            
            // add all video tracks in asset
            let videoMediaTracks = asset.tracks(withMediaType: .video)
            videoMediaTracks.forEach{ (videoMediaTrack) in
                
                //                maxWidth = max(videoMediaTrack.naturalSize.width, maxWidth)
                //                maxHeight = max(videoMediaTrack.naturalSize.height, maxHeight)
                
                try? videoTrack?.insertTimeRange(timeRange, of: videoMediaTrack, at: kCMTimeZero)
            }
            
            if video.muted {
                return
            }
            
            // add all audio tracks in asset
            let audioMediaTracks = asset.tracks(withMediaType: .audio)
            audioMediaTracks.forEach {(audioMediaTrack) in
                try? audioTrack?.insertTimeRange(timeRange, of: audioMediaTrack, at: kCMTimeZero)
            }
        }
        
        // TODO: check this shit out for video rotation.
        // http://stackoverflow.com/questions/12136841/avmutablevideocomposition-rotated-video-captured-in-portrait-mode
        // http://stackoverflow.com/questions/27627610/video-not-rotating-using-avmutablevideocompositionlayerinstruction
        // And where would we be w/o Ray Wenderlich?
        // https://www.raywenderlich.com/13418/how-to-play-record-edit-videos-in-ios
        
        let notificationCenter = NotificationCenter.default
        guard let exporter = AVAssetExportSession(asset: mixComposition,
                                                  presetName: AVAssetExportPresetHighestQuality) else { return false }
        exporter.outputURL = outputUrl
        exporter.outputFileType = .mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.exportAsynchronously(completionHandler: {
            switch exporter.status {
            case .completed:
                // we can be confident that there is a URL because
                // we got this far. Otherwise it would've failed.
                if let url = exporter.outputURL {
                    print("exportVideo SUCCESS!")
                    notificationCenter.post(name: BBVideoUtils.exportCompleteNotification, object: url)
                } else {
                    notificationCenter.post(name: BBVideoUtils.exportCompleteNotification, object: exporter.error)
                }
                
            case .exporting:
                let progress = exporter.progress
                print("exportVideo \(progress)")
                
                notificationCenter.post(name: BBVideoUtils.exportProgressNotification, object: progress)
                
            case .failed:
                notificationCenter.post(name: BBVideoUtils.exportCompleteNotification, object: exporter)
                
            default: break
            }
        })
        return true
    }
}

