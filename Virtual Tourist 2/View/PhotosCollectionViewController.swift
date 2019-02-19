//
//  PhotosCollectionViewController.swift
//  Virtual Tourist 2
//
//  Created by Bashayer  on 08/02/2019.
//  Copyright © 2019 Bashayer. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosCollectionViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var toolbarButton: UIBarButtonItem!
    
    
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    var selectedPhotos: [IndexPath]! = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        
        collectionView.allowsMultipleSelection = true
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        createAnnotation()
        
        setupFetchedResultsController()
        if fetchedResultsController.fetchedObjects!.count == 0 {
            loadPhotos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    
    
    @IBAction func updateCollection(_ sender: Any) {
        if hasSelectedPhotos() {
             deleteSelectedPhotos()
        } else {
            fetchedResultsController.fetchedObjects?.forEach() { photo in
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("Unable to delete photo. \(error.localizedDescription)")
                }
            }
            self.collectionView.reloadData()
            loadPhotos()
        }
        
        try? dataController.viewContext.save()
    }
    
    
    func createAnnotation(){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        mapView.addAnnotation(annotation)
        
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        
        self.mapView.isZoomEnabled = false;
        self.mapView.isScrollEnabled = false;
        self.mapView.isUserInteractionEnabled = false;
        
        mapView.setRegion(region, animated: true)
        
        
    }
    
    func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    func loadPhotos() {
        
        let flickrCall = Requests.sharedInstance
        
        flickrCall.getPhotosforLocation(pin.latitude, pin.longitude, 20) { (success, photos) in
            
            if !success {
                
                let alert = UIAlertController(title: "Unable to download images ", message: "Unable to download images from Flickr.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
                return
            }
            
        
            print("Flickr images fetched \(photos!.count)")
            
            
            
            photos!.forEach() { photo_url in
                let photo = Photos(context: self.dataController.viewContext)
                photo.url = URL(string: photo_url["url_m"] as! String)?.absoluteString
                photo.pin = self.pin
                
                do {
                    try self.dataController.viewContext.save()
                } catch  {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void){
        
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                
                let alert = UIAlertController(title: "Could not download image ", message: "Could not download image", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                
                completionHandler(data, nil)
            }
        }
        task.resume()
    }
    
}

extension PhotosCollectionViewController: MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.fetchedObjects!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionCell", for: indexPath) as! CollectionViewCell
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        if let data = photo.imageData {
            cell.image.image = UIImage(data: data)
            cell.activityIndicator.isHidden = true
        } else {
            //cell.image.image = UIImage(named: "image")
            //cell.contentView.alpha = 1.0
            cell.activityIndicator.isHidden = false
           cell.activityIndicator.startAnimating()
            
            downloadImage(imagePath: photo.url!) { imageData, errorString in
                if let imageData = imageData {
                    DispatchQueue.main.async {
                        cell.image.image = UIImage(data: imageData)
                    }
                    photo.imageData = imageData
                    try? self.dataController.viewContext.save()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha = 0.4
        
        if selectedPhotos.contains(indexPath) == false {
            selectedPhotos.append(indexPath)
        }
        selectPhotoActionButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha = 1.0
        
        if let index = selectedPhotos.firstIndex(of: indexPath) {
            selectedPhotos.remove(at: index)
        }
        selectPhotoActionButton()
    }
    
    func selectPhotoActionButton() {
        if hasSelectedPhotos() {
            toolbarButton.title = "Delete Selected Photos"
            toolbarButton.tintColor = .red
        }
        else {
            toolbarButton.title = "Update Collection"
            toolbarButton.tintColor = .blue
        }
    }
    
    func hasSelectedPhotos() -> Bool {
        if selectedPhotos.count == 0 {
            return false
        }
        return true
    }
   
     func deleteSelectedPhotos() {
     let photos = selectedPhotos.map() { fetchedResultsController.object(at: $0) }
     photos.forEach() { photo in
     dataController.viewContext.delete(photo)
     selectedPhotos.removeAll()
     
     try? dataController.viewContext.save()
     }
     
     selectPhotoActionButton()
     } 
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.collectionView.insertItems(at: [newIndexPath!])
            
        case .delete:
            self.collectionView.deleteItems(at: [indexPath!])
            
        case .move:
            self.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        case .update:
            self.collectionView.reloadItems(at: [indexPath!])
        }
    }
    
    
    
}
