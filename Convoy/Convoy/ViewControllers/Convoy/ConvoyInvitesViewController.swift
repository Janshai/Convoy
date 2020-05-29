//
//  ConvoyInvitesViewController.swift
//  Convoy
//
//  Created by Jack Adams on 28/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit
import Eureka
import GooglePlacesRow
import GooglePlaces

class ConvoyInvitesViewController: FormViewController {
    var usingCurrentLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .white
        view.backgroundColor = .white
        navigationItem.title = "Convoy Invites"
        
        setupIndicator()
        ConvoyViewModel.getConvoyInvites() { [weak self] VMs in
            if let strongSelf = self {
                if VMs.count == 0 {
                    strongSelf.form +++ LabelRow() { row in
                        row.title = "You currently have no Convoy Invites."
                        row.disabled = true
                        row.evaluateDisabled()
                    }
                } else {
                    for vm in VMs {
                        let inviteString = "You have been invited to the Convoy: " + vm.name + ", travelling to " + vm.destinationName
                        strongSelf.form +++ LabelRow() { row in
                            row.title = inviteString
                            row.cell.textLabel?.numberOfLines = 0
                            }
                            <<< ActionSheetRow<String>() { row in
                                row.options = ["Accept", "Decline"]
                                row.selectorTitle = "Respond"
                                row.title = "Respond"
                                row.tag = "respond" + vm.convoy.convoyID!
                            }.onChange() { [weak self] row in
                                let value = row.value
                                if let strongSelf2 = self {
                                    if value == "Decline" {
                                        vm.declineInvite()
                                        
                                    } else {
                                        strongSelf2.setAcceptSectionHidden(to: false, forConvoyID: vm.convoy.convoyID!)
                                    }
                                    row.disabled = true
                                    row.evaluateDisabled()
                                }
                                
                            }
                            +++ Section("Choose Your Start Location") { section in
                                section.tag = "startLocation" + vm.convoy.convoyID!
                                section.hidden = true
                            }
                            <<< GooglePlacesTableRow() { row in
                                row.placeholder = "Start Location"
                                row.tag = "start" + vm.convoy.convoyID!
                                var ruleSet = RuleSet<GooglePlace>()
                                let locationRule = RuleClosure<GooglePlace>() { place in
                                    if let data = place {
                                        switch data {
                                        case .prediction(_):
                                            return nil
                                        case .userInput(let value):
                                            if value == "Current Location" {
                                                return nil
                                            } else {
                                                return ValidationError(msg: "Invalid Location")
                                            }
                                        }
                                    } else {
                                        return ValidationError(msg: "Invalid Location")
                                    }
                                }
                                ruleSet.add(rule: RuleRequired())
                                ruleSet.add(rule: locationRule)
                                row.add(ruleSet: ruleSet) // We can use GooglePlace() as a rule
                                row.cell.useTimer = true
                                row.cell.timerInterval = 1.0
                                let filter = GMSAutocompleteFilter()
                                filter.country = "GB"
                                row.placeFilter = filter
                                row.validationOptions = .validatesOnDemand
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
                                    if let row: GooglePlacesTableRow = strongSelf.form.rowBy(tag: "start" + vm.convoy.convoyID!) {
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
                            +++ Section() { section in
                                section.tag = "confirm" + vm.convoy.convoyID!
                                section.hidden = true
                            }
                            <<< ButtonRow() {row in
                                row.title = "Confirm Accept"
                            }.onCellSelection() { [weak self] cell, row in
                                if let strongSelf2 = self {
                                    let errors = strongSelf2.form.validate()
                                    if errors.isEmpty {
                                        var data: [String: Any] = [:]
                                        let startRow: GooglePlacesTableRow? = strongSelf2.form.rowBy(tag: "start" + vm.convoy.convoyID!)
                                        switch startRow?.value {
                                        case .prediction(prediction: let pred):
                                            data["startLocationPlaceName"] = pred.attributedPrimaryText.string

                                            strongSelf2.getLocation(from: pred.placeID, onCompletion: { location in
                                                data["start"] = ["long": Double(location.longitude), "lat": Double(location.latitude)]
                                                vm.acceptInvite(withStartLocation: data)
                                            })
                                        case .userInput(value: let input):
                                            if input == "Current Location" {
                                           
                                                strongSelf2.getCurrentLocation() { place in
                                                    data["startLocationPlaceName"] = place.name
                                                    let location = place.coordinate
                                                    data["start"] = ["long": Double(location.longitude), "lat": Double(location.latitude)]
                                                    vm.acceptInvite(withStartLocation: data)
                                                }
                                            
                                            }
                                        }
                                        
                                        
                                        strongSelf2.setAcceptSectionHidden(to: true, forConvoyID: vm.convoy.convoyID!)
                                        
                                    } else {
                                        let errorStrings = errors.map({$0.msg})
                                        let message = errorStrings.joined(separator: "\n")
                                        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Okay", style: .default))
                                        strongSelf2.present(alert, animated: true, completion: nil)
                                    }
                                    
                                }
                        }
                            <<< ButtonRow() { row in
                                row.title = "Cancel"
                            }.onCellSelection() { [weak self] cell, row in
                                if let strongSelf2 = self {
                                    strongSelf2.setAcceptSectionHidden(to: true, forConvoyID: vm.convoy.convoyID!)
                                    let respondRow = self?.form.rowBy(tag: "respond" + vm.convoy.convoyID!)
                                    respondRow?.disabled = false
                                    respondRow?.evaluateDisabled()
                                }
                        }
                    }
                }
                strongSelf.tableView.alpha = 0
                strongSelf.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    
                    UIView.animate(withDuration: 0.5) { [weak self] in
                        self?.tableView.alpha = 1.0
                    }
                    
                    
                }
                let indicator = strongSelf.tableView.backgroundView as? UIActivityIndicatorView
                indicator?.stopAnimating()
                
                
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    func setAcceptSectionHidden(to bool: Bool, forConvoyID id: String) {
        let section = form.sectionBy(tag: "startLocation" + id)
        let section2 = form.sectionBy(tag: "confirm" + id)
        section?.hidden = bool ? true : false
        section2?.hidden = bool ? true : false
        section2?.evaluateHidden()
        section?.evaluateHidden()
    }
    
    func setupIndicator() {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .gray
        tableView.backgroundView = indicator
        indicator.startAnimating()
    }
    
    func getCurrentLocation(callback: @escaping (GMSPlace) -> Void) {
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.coordinate.rawValue) |
        UInt(GMSPlaceField.placeID.rawValue))!
        
        GMSPlacesClient.shared().findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList, let place = placeLikelihoodList.first?.place {
                callback(place)
            }
        })
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



