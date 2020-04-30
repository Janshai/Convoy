//
//  AddConvoyViewController.swift
//  Convoy
//
//  Created by Jack Adams on 26/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit
import Eureka
import GooglePlacesRow
import GooglePlaces

class AddConvoyViewController: ConvoyFriendInviteViewController {
    
    var usingCurrentLocation = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white
        view.backgroundColor = .white
        navigationItem.title = "Add Convoy"
        
        
        
        
        form +++ Section("Basic Details")
            <<< NameRow("convoyName", {$0.placeholder = "Convoy Name"})
            <<< GooglePlacesTableRow() { row in
                row.placeholder = "Destination"
                row.tag = "destination" // Upon parsing a form you get a nice key if you use a tag
                row.add(ruleSet: RuleSet<GooglePlace>()) // We can use GooglePlace() as a rule
                row.cell.useTimer = true
                row.cell.timerInterval = 1.0
                let filter = GMSAutocompleteFilter()
                filter.country = "GB"
                row.placeFilter = filter
                row.validationOptions = .validatesOnChangeAfterBlurred
                row.cell.textLabel?.textColor = UIColor.black
                row.onNetworkingError = { error in
                    print(error!.localizedDescription)
                }
            }
            +++ inviteFriendsSection(withDeletion: true)
            +++ Section("Your Journey Details")
            <<< GooglePlacesTableRow() { row in
                row.placeholder = "Start Location"
                row.tag = "start" // Upon parsing a form you get a nice key if you use a tag
                row.add(ruleSet: RuleSet<GooglePlace>()) // We can use GooglePlace() as a rule
                row.cell.useTimer = true
                row.cell.timerInterval = 1.0
                let filter = GMSAutocompleteFilter()
                filter.country = "GB"
                row.placeFilter = filter
                row.validationOptions = .validatesOnChangeAfterBlurred
                row.cell.textLabel?.textColor = UIColor.black
                row.onNetworkingError = { error in
                    print(error!.localizedDescription)
                }
            }
            <<< ButtonRow("useCurrentLocation", { row in
                row.title = "Use Current Location"
                
            }).onCellSelection { [weak self] (cell, row) in
                
                if let strongSelf = self {
                    if strongSelf.usingCurrentLocation {
                        row.title = "Use Current Location"
                    } else {
                        row.title = "Enter a Start Location"
                    }
                    strongSelf.usingCurrentLocation = !strongSelf.usingCurrentLocation
                    cell.update()
                    if let row: GooglePlacesTableRow = strongSelf.form.rowBy(tag: "start") {
                        if strongSelf.usingCurrentLocation {
                            row.value = .userInput(value: "Current Location")
                            row.disabled = true
                        } else {
                            row.value = .userInput(value: "")
                            row.disabled = false
                        }
                        
                        row.cell.update()
                        row.evaluateDisabled()
                    }
                }
                
            }
            +++ ButtonRow() { row in
                
                row.title = "Complete"
            }.onCellSelection() { [weak self] cell, row in
                row.disabled = true
                cell.alpha = 0.5
                let indicator = UIActivityIndicatorView()
                let buttonHeight = cell.bounds.size.height
                let buttonWidth = cell.bounds.size.width
                indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
                cell.addSubview(indicator)
                indicator.startAnimating()
                row.evaluateDisabled()
                if let strongSelf = self {
                    strongSelf.createConvoy() { data in
                        ConvoyViewModel.createConvoy(with: data) { [weak self] in
                            indicator.stopAnimating()
                            if let strongSelf = self {
                                strongSelf.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                } else {
                    //error
                }
                
                
            }
        
        

        // Do any additional setup after loading the view.
    }
    
    func createConvoy(onCompletion callback: @escaping ([String:Any]) -> Void) {
        //validation
        let group = DispatchGroup()
        var data: [String: Any] = [:]
        let nameRow: NameRow? = form.rowBy(tag: "convoyName")
        data["name"] = nameRow?.value
        let destinationRow: GooglePlacesTableRow? = form.rowBy(tag: "destination")
        switch destinationRow?.value {
        case .prediction(prediction: let pred):
            data["destinationPlaceName"] = pred.attributedPrimaryText.string
            group.enter()
            getLocation(from: pred.placeID, onCompletion: { location in
                data["destination"] = ["long": Double(location.longitude), "lat": Double(location.latitude)]
                group.leave()
            })
        default:
            //error
            return
        }

        let values = (self.form.values()["friends"]!! as! [String]).compactMap { $0 }
        var friendIDs: [String] = []
        for v in values {
            let index = friends?.firstIndex(where: {$0.name == v})
            let id = friends![index!].user.userUID
            friendIDs.append(id)
        }
        
        data["friends"] = friendIDs
        
        let startRow: GooglePlacesTableRow? = form.rowBy(tag: "start")
        switch startRow?.value {
        case .prediction(prediction: let pred):
            data["startLocationPlaceName"] = pred.attributedPrimaryText.string
            group.enter()
            getLocation(from: pred.placeID, onCompletion: { location in
                data["start"] = ["long": Double(location.longitude), "lat": Double(location.latitude)]
                group.leave()
            })
        case .userInput(value: let input):
            if input == "Current Location" {
                // get location
                return
            }
        default:
            //error
            return
        }
        
        group.notify(queue: DispatchQueue.main) {
            callback(data)
        }
        
        
        
    }
    
    
    func getLocation(from placeID: String, onCompletion callback: @escaping (CLLocationCoordinate2D) -> Void) {
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.coordinate.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        
        GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
            (place: GMSPlace?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                callback(place.coordinate)
            }
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
