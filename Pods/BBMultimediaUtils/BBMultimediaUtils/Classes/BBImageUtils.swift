//
//  BBImageUtils.swift
//  BBMultimediaUtils
//
//  Created by Blake Barrett on 2/28/18.
//

import Foundation
import UIKit

public class BBImageUtils {
    
    public static func loadImage(contentsOf url: URL?, onComplete: ((UIImage?) -> Void)?) {
        DispatchQueue.global().async {
            guard let url = url,
                let data = try? NSData(contentsOf: url) as Data else { return }
            DispatchQueue.main.async {
                onComplete?(UIImage(data: data))
            }
        }
    }
}
