//
//  Flickr.swift
//  Virtual Tourist 2
//
//  Created by Bashayer  on 08/02/2019.
//  Copyright © 2019 Bashayer. All rights reserved.
//

import Foundation


class Requests {
    
    static let sharedInstance = Requests()
    
    func getPhotosforLocation(_ latitude: Double, _ longitude: Double,_ page: Int, _ completion: @escaping (_ success: Bool, _ data: [[String: Any]]? ) -> Void) {
        
        let params = [ParameterKeys.APIKey: Constant.APIKey,
                      ParameterKeys.Method: Methods.SearchMethod,
                      ParameterKeys.Extras: ParameterValues.MediumURL,
                      ParameterKeys.Format: ParameterValues.ResponseFormat,
                      ParameterKeys.Lat: String(describing: latitude),
                      ParameterKeys.Lon: String(describing: longitude),
                      ParameterKeys.Page: "\(randomPage.randomPageNumber())",
                      ParameterKeys.PerPage: "20",
                      ParameterKeys.NoJSONCallback: ParameterValues.DisableJSONCallback] as [String: Any]
        
        var components = URLComponents()
        components.scheme = Constant.APIScheme
        components.host = Constant.APIHost
        components.path = Constant.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        let request = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            func showError(_ errorString: String) {
                print(errorString)
                completion(false, nil)
                return
            }
            
            guard (error == nil) else {
                showError("There was an error with your request.")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode < 300 else {
                showError("Unsuccessful request response retured.")
                return
            }
            
            let parsedData: [String: AnyObject]!
            do {
                parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject]
            } catch {
                showError("Could not parse data")
                return
            }
            
            guard let photos = parsedData[ResponseKeys.Photos] as! [String: Any]?,
                let photo = photos[ResponseKeys.Photo] as! [[String: Any]]? else {
                    showError("Could not extract photos and/or photo dict")
                    return
            }
            
            completion(true, photo)
        }
        task.resume()
    }
    
    struct randomPage {
        static func randomPageNumber() -> Int {
            return Int.random(in: 0 ... 10)
        }
    }
}
