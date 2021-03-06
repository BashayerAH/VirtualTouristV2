//
//  Constant.swift
//  Virtual Tourist 2
//
//  Created by Bashayer  on 08/02/2019.
//  Copyright © 2019 Bashayer. All rights reserved.
//

import Foundation
import UIKit

struct Constant {
    static let APIScheme = "https"
    static let APIHost = "api.flickr.com"
    static let APIPath = "/services/rest"
    static let APIKey = "b33418d8a589488560088006a118274b"
    
    static let SearchBBoxHalfWidth = 1.0
    static let SearchBBoxHalfHeight = 1.0
    static let SearchLatRange = (-90.0, 90.0)
    static let SearchLonRange = (-180.0, 180.0)
}

struct ParameterKeys {
    static let APIKey = "api_key"
    static let Method = "method"
    static let Extras = "extras"
    static let Format = "format"
    static let GalleryID = "gallery_id"
    static let NoJSONCallback = "nojsoncallback"
    static let SafeSearch = "safe_search"
    static let Text = "text"
    static let BoundingBox = "bbox"
    static let PerPage = "per_page"
    static let Page = "page"
    static let Lat = "lat"
    static let Lon = "lon"
}

struct ParameterValues {
    static let ResponseFormat = "json"
    static let MediumURL = "url_m"
    static let DisableJSONCallback = "1" /* 1 means "yes" */
    static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
    static let GalleryID = "5704-72157622566655097"
    static let UseSafeSearch = "1"
}

struct Methods {
    static let SearchMethod = "flickr.photos.search"
}

struct ResponseKeys {
    static let Photos = "photos"
    static let Photo = "photo"
    static let Status = "stat"
    static let Title = "title"
    static let Pages = "pages"
    static let Total = "total"
    static let OKStatus = "ok"

}
/*
 struct Constants {
 
 // MARK: Flickr
 struct Flickr {
 static let APIScheme = "https"
 static let APIHost = "api.flickr.com"
 static let APIPath = "/services/rest"
 
 static let SearchBBoxHalfWidth = 1.0
 static let SearchBBoxHalfHeight = 1.0
 static let SearchLatRange = (-90.0, 90.0)
 static let SearchLonRange = (-180.0, 180.0)
 }
 
 // MARK: Flickr Parameter Keys
 struct FlickrParameterKeys {
 static let Method = "method"
 static let APIKey = "api_key"
 static let GalleryID = "gallery_id"
 static let Extras = "extras"
 static let Format = "format"
 static let NoJSONCallback = "nojsoncallback"
 static let SafeSearch = "safe_search"
 static let Text = "text"
 static let BoundingBox = "bbox"
 static let Page = "page"
 }
 
 // MARK: Flickr Parameter Values
 struct FlickrParameterValues {
 static let SearchMethod = "flickr.photos.search"
 static let APIKey = "b33418d8a589488560088006a118274b"
 static let ResponseFormat = "json"
 static let DisableJSONCallback = "1" /* 1 means "yes" */
 static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
 static let GalleryID = "5704-72157622566655097"
 static let MediumURL = "url_m"
 static let UseSafeSearch = "1"
 }
 
 // MARK: Flickr Response Keys
 struct FlickrResponseKeys {
 static let Status = "stat"
 static let Photos = "photos"
 static let Photo = "photo"
 static let Title = "title"
 static let MediumURL = "url_m"
 static let Pages = "pages"
 static let Total = "total"
 }
 
 // MARK: Flickr Response Values
 struct FlickrResponseValues {
 static let OKStatus = "ok"
 }
 
 
 }
 
 
 */
