//
//  MapViewController.swift
//  TestProject
//
//  Created by ABei on 3/27/18.
//  Copyright © 2018 ABei. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import Firebase
import GoogleMaps
import GooglePlaces
import FBSDKCoreKit
import FBSDKLoginKit

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var logoutButton: UIButton!
    
    var mapView = GMSMapView()
    
    var markers = [Marker]()
    
    let manager = CLLocationManager()
    
    var camera = GMSCameraPosition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        view = mapView
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        manager.delegate = self
        manager.startUpdatingLocation()
        view.addSubview(logoutButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .utility).async {
            self.uploadMarkers() {
                DispatchQueue.main.async {
                    self.setMarkers(in: self.mapView)
                }
            }
        }
    }
    
    @IBAction func logOutButtonAction(_ sender: Any) {
        if FBSDKAccessToken.current() != nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        } else {
            AuthService.authService.logOut()
        }
        performSegue(withIdentifier: "fromMapToLogin", sender: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        mapView.animate(to: camera)
        //
        let marker = GMSMarker()
        marker.position = self.camera.target
        marker.snippet = "Hello World"
        marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
        marker.map = self.mapView
        //
        let circleCenter = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
        let circle = GMSCircle(position: circleCenter, radius: 100)
        circle.fillColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.09)
        circle.strokeColor = UIColor.red
        circle.map = self.mapView
        //
        manager.stopUpdatingLocation()
    }
    
    func uploadMarkers(completion: @escaping () -> Void) {
        let userID = UserDefaults.standard.value(forKey: "uid") != nil ? UserDefaults.standard.value(forKey: "uid") : UserDefaults.standard.value(forKey: "facebookUID")
        AuthService.authService.dataBaseReference.child("Markers").child(userID as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                for key in (value.allKeys) {
                    let arr = value[key] as! NSDictionary
                    let name = arr.value(forKey: "name") as! String
                    let latitude = arr.value(forKey: "latitude")! as! String
                    let longitude = arr.value(forKey: "longitude")! as! String
                    let timeID = String(describing: key)
                    let mark = Marker(name: name, latitude: Double(latitude)!, longitude: Double(longitude)!, timeID: timeID)
                    self.markers.append(mark)
                }
                completion()
            }
        }, withCancel: { (error) in
            print("ERRORR")
        })
    }
    
    func setMarkers(in map: GMSMapView) {
        for mark in markers {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: mark.latitude, longitude: mark.longitude)
            marker.snippet = mark.name
            marker.map = map
            view = map
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let alertController = UIAlertController(title: "Add new marker", message: nil, preferredStyle: .alert)
        DispatchQueue.main.async {
            alertController.addTextField(configurationHandler: {(textField) in
                textField.text = ""
                textField.placeholder = "Name of Place"
            })
        }
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alert:UIAlertAction) in
            let name = alertController.textFields![0]
            if name.text != "" {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                marker.snippet = name.text
                marker.map = mapView
                let date = Date()
                var timeID = String(describing: date.timeIntervalSince1970)
                let index = timeID.index(of: ".")
                timeID.remove(at: index!)
                let someVar = Database.database().reference()
                let userID : String = (Auth.auth().currentUser?.uid)!
                let markPost = ["latitude":"\(marker.position.latitude)", "longitude":"\(marker.position.longitude)", "name":"\(String(describing: name.text))"]
                let mark = Marker(name: name.text!, latitude: marker.position.latitude, longitude: marker.position.longitude, timeID: timeID)
                self.markers.append(mark)
                someVar.child("Markers").child(userID).child(timeID).updateChildValues(markPost)
                self.view = mapView
            }
        }))
        let alertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let alertController = UIAlertController(title: "delete marker", message: nil, preferredStyle: .alert)
        let alertAction1 = UIAlertAction(title: "Ok", style: .default, handler: {(alert:UIAlertAction) in
            for mark in self.markers {
                if marker.position.latitude == mark.latitude || marker.position.longitude == mark.longitude {
                    let dataRef = Database.database().reference()
                    var markRef = DatabaseReference()
                    if UserDefaults.standard.value(forKey: "uid") != nil {
                        markRef = dataRef.ref.child("Markers").child(UserDefaults.standard.value(forKey: "uid") as! String).child(mark.timeID)
                    } else {
                        markRef = dataRef.ref.child("Markers").child(UserDefaults.standard.value(forKey: "facebookUID") as! String).child(mark.timeID)
                    }
                    markRef.removeValue()
                    marker.map = nil
                }
            }
        })
        alertController.addAction(alertAction1)
        let alertAction2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(alertAction2)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        return true
    }
}
