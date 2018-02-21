//
//  GiphySearchAPI.swift
//  stchy
//
//  Created by Blake Barrett on 2/20/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import Foundation

public enum Rating: String {
    case G = "G",
        PG = "PG",
        PG13 = "PG-13",
        R = "R"
}

public class GiphySearchAPI {
    
    private static let baseSearchUrl = "https://api.giphy.com/v1/gifs/search?api_key=WvKCzzlxrgR5wptk84eVyru6wOSnmzYh&q=&limit=25&offset=0&lang=en&rating="
    
    public static func search(query: String, rating: Rating = Rating.PG, completion: @escaping ([GiphyResult]?) -> Void) {
        let queryString = baseSearchUrl + rating.rawValue + "&q=" + query
        guard let queryURL = URL(string: queryString) else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: queryURL) {data, response, error in
            guard let data = data else { completion(nil); return }
            if let resultsJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let results = resultsJSON?["data"] as? [[String: Any]] {
                var allEntries = [GiphyResult]()
                results.forEach({ (result) in
                    allEntries.append(GiphyResult(json: result))
                })
                completion(allEntries)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
