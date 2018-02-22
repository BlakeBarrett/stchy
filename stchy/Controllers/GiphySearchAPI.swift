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
    
    private static let baseSearchUrl = "https://api.giphy.com/v1/gifs/search?api_key=WvKCzzlxrgR5wptk84eVyru6wOSnmzYh&lang=en"
    
    public static func search(query: String, rating: Rating = Rating.PG, maxResults: Int = 25, page: Int = 0, completion: @escaping ([GiphyResult]?) -> Void) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(nil)
            return
        }
        let queryString = baseSearchUrl + "&rating=" + rating.rawValue + "&q=" + query + "&limit=" + String(describing: maxResults) + "&offset=" + String(describing: page)
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
