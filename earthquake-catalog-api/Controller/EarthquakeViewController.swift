//
//  ViewController.swift
//  earthquake-catalog-api
//
//  Created by Robby King on 2/2/19.
//  Copyright © 2019 Robby King. All rights reserved.
//

import MapKit
import UIKit
import WebKit

class EarthquakeViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noOfDaysPicker: UIPickerView!
    @IBOutlet weak var pickerHeaderView: UIView!
    @IBOutlet weak var showNoOfDaysButton: UIButton!
    @IBOutlet weak var tapToChangeButton: UIButton!
    
    //MARK: Instance Variables
    let dateFormatter = DateFormatter()
    var daysToShow = 7
    var detailsURLs = [Int:String]()
    var featureIndex = 0
    var features = [Feature]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNoOfDaysButtonTitle()
        configureViewController()
        configureDateFormatter()
        configureMapView()
        configurePickerView()
        getEarthQuakeData()
    }
    
    // MARK: Private functions
    fileprivate func setNoOfDaysButtonTitle() {
        showNoOfDaysButton.setTitle("No of days to display: \(daysToShow)", for: .normal)
        showNoOfDaysButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
        tapToChangeButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
    }
    
    fileprivate func configureViewController() {
        title = "Earthquakes!"
    }
    
    fileprivate func configureDateFormatter() {
        dateFormatter.dateFormat = "YYYY-MM-dd"
    }
    
    fileprivate func configureMapView() {
        mapView.isRotateEnabled = true
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        let location = CLLocationCoordinate2D(latitude: 45.5236, longitude: -122.6750)
        let span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func configurePickerView() {
        noOfDaysPicker.delegate = self
        noOfDaysPicker.dataSource = self
        noOfDaysPicker.isHidden = true
        noOfDaysPicker.backgroundColor = .white
        view.bringSubviewToFront(noOfDaysPicker)
    }
    
    fileprivate func getStartDateString() -> String {
        var differenceInDays = daysToShow
        differenceInDays.negate()
        
        let startDate = Calendar.current.date(byAdding: .day, value: differenceInDays, to: Date())
        return dateFormatter.string(from: startDate ?? Date())
    }
    
    fileprivate func getEndDateString() -> String {
        return dateFormatter.string(from: Date())
    }
    
    fileprivate func getEarthQuakeData() {
        loadingView.isHidden = false
        let endDateString = getEndDateString()
        let startDateString = getStartDateString()
        let apiURL = "https://earthquake.usgs.gov"
        let apiEndPoint = "/fdsnws/event/1/query"
        let apiParams = "?format=geojson&starttime=\(startDateString)&endtime=\(endDateString)"
        let networkServices = NetworkServices()
        networkServices.makeNetworkRequest(apiURL: URL(string: apiURL + apiEndPoint + apiParams)!) { (response) in
            guard let response = response else {
                return
            }
            do {
                let earthquakes = try JSONDecoder().decode(Earthquakes.self, from: response)
                self.features = earthquakes.features
                DispatchQueue.main.async {
                    self.setAnnotations()
                }
            } catch {
                print("Oops! Let's take a look: \(error)")
            }
        }
    }
    
    fileprivate func setAnnotations() {
        for feature in self.features{
            let coordinates = feature.geometry.coordinates
            if let latitude = coordinates[1], let longitude = coordinates[0] {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                if self.mapView.visibleMapRect.contains(MKMapPoint(coordinate)) {
                    let annotation = EarthquakePointAnnotation(detailsURL: feature.properties.url)
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    annotation.title = feature.properties.place
                    let type = feature.properties.type
                    if let magnitude = feature.properties.mag {
                        annotation.subtitle = "Magnitude \(magnitude); Type: \(type)."
                    }
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
        loadingView.isHidden = true
    }
    
    // MARK: IBActions
    @IBAction func applyNoOfDaysPicker(_ sender: Any) {
        // Clear the previous annotations, so we don't show the user
        // data they do not wish to see.
        mapView.removeAnnotations(mapView.annotations)
        daysToShow = noOfDaysPicker.selectedRow(inComponent: 0) + 1
        noOfDaysPicker.isHidden = true
        pickerHeaderView.isHidden = true
        setNoOfDaysButtonTitle()
        getEarthQuakeData()
    }
    
    @IBAction func cancelNoOfDaysPicker(_ sender: Any) {
        noOfDaysPicker.isHidden = true
        pickerHeaderView.isHidden = true
    }
    
    @IBAction func toggleNoOfDaysPicker(_ sender: UIButton) {
        let rowToselect = daysToShow - 1
        noOfDaysPicker.selectRow(rowToselect, inComponent: 0, animated: false)
        noOfDaysPicker.isHidden = !noOfDaysPicker.isHidden
        pickerHeaderView.isHidden = !pickerHeaderView.isHidden
    }
}

// MARK: MKMapViewDelegate Protocol Conformance
extension EarthquakeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let detailsURLString = detailsURLs[view.tag], let detailsURL = URL(string: detailsURLString) {
            let webViewConroller = UIViewController()
            let webView = WKWebView(frame: self.view.frame)
            let request: URLRequest = URLRequest(url: detailsURL)
            webView.load(request)
            webViewConroller.view.addSubview(webView)
            
            // For some reason the webview isn't loding its request URL in the
            // simulator, though it works fine on the device. It appears to be an
            // Xcode bug involving the debugging session. (The links are all HTTPS
            // so it doesn't appear to be an issue with App Transport Security.)
            self.navigationController?.pushViewController(webViewConroller, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        setAnnotations()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? EarthquakePointAnnotation {
            let identifier = "annotation"
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            let infoButton = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = infoButton
            annotationView.canShowCallout = true
            
            // Since there isn't an easy way to store data in an annotation view,
            // what I'm doing here is using the tag as the key value in a dictionary
            // that contains the details URLs.
            featureIndex += 1
            detailsURLs[featureIndex] = annotation.detailsURL
            annotationView.tag = featureIndex
            return annotationView
        } else {
            return nil
        }
    }
}

// MARK: UIPickerViewDataSource Protocol Conformance
extension EarthquakeViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
}

// MARK: UIPickerViewDelegate Protocol Conformance
extension EarthquakeViewController: UIPickerViewDelegate {}
