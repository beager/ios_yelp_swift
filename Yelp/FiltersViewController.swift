//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Bill Eager on 9/5/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate, ExpandCollapseCellDelegate {

    let sections = ["categories", "distance", "sort"]
    
    @IBOutlet weak var tableView: UITableView!
    
    var categoriesCollapsed: Bool = true
    
    var categories: [[String:String]]!
    var switchStates = [Int:Bool]()
    var dealSwitchState: Bool = false
    
    var sortingChoice = 0
    var distanceChoice = 0
    var collapseDistance = true
    var collapseSort = true
    
    weak var delegate: FiltersViewControllerDelegate?
    
    let CellIdentifier = "SwitchCell", ExpandCollapseViewIdentifier = "ExpandCollapseCell"

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorInset = UIEdgeInsetsZero
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: ExpandCollapseViewIdentifier, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: ExpandCollapseViewIdentifier)
        
        categories = yelpFormInfo["categories"]!
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        var filters = [String: AnyObject]()
        
        var selectedCategories = [String]()
        for (row,isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        filters["deals"] = dealSwitchState
        filters["distance"] = getSectionById(2)[distanceChoice]["code"]
        filters["sortMode"] = getSectionById(1)[sortingChoice]["code"]
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return yelpFormInfo.count
    }
    
    func getSectionById(id: Int) -> [[String: String]] {
        switch id {
        case 0:
            return yelpFormInfo["deals"]!
        case 1:
            return yelpFormInfo["sort"]!
        case 2:
            return yelpFormInfo["distance"]!
        case 3:
            return yelpFormInfo["categories"]!
        default:
            return [[String:String]]()
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1;
        case 1:
            return collapseSort ? 1 : 3
        case 2:
            return collapseDistance ? 1 : 5
        case 3:
            return categoriesCollapsed ? 4 : getSectionById(3).count + 1
        default:
            return 0
        }
    }


    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [nil, "Sort", "Distance", "Categories"][section]
    }

    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    // Deselect active row on tap
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.section {
        case 1:
            if collapseSort {
                collapseSort = false
            } else {
                sortingChoice = indexPath.row
                collapseSort = true
            }
            break
        case 2:
            if collapseDistance {
                collapseDistance = false
            } else {
                distanceChoice = indexPath.row
                collapseDistance = true
            }
            break
        default:
            return
        }
        
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func getExpandCollapseCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ExpandCollapseViewIdentifier) as! ExpandCollapseCell
        cell.titleLabel?.text = categoriesCollapsed ? "See all" : "See fewer"
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 3 && indexPath.row == tableView.numberOfRowsInSection(3) - 1 {
            return getExpandCollapseCell()
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! SwitchCell
        
        cell.onSwitch.hidden = false
        cell.onSwitch.on = false
        cell.accessoryType = .None
        cell.switchLabel?.text = ""
        let theOption: [String: String] = getSectionById(indexPath.section)[indexPath.row]
        cell.switchLabel?.text = theOption["name"]
        println(indexPath)
        switch indexPath.section {
        case 1:
            if collapseSort {
                cell.onSwitch.hidden = true
                let chosenOption = getSectionById(indexPath.section)[sortingChoice]
                cell.switchLabel?.text = chosenOption["name"]
            } else {
                cell.onSwitch.hidden = true
                if sortingChoice == indexPath.row {
                    cell.accessoryType = .Checkmark
                }
                cell.switchLabel?.text = theOption["name"]
            }
            break
        case 2:
            cell.onSwitch.hidden = true
            if collapseDistance {
                // fill in the real answer
                let chosenOption = getSectionById(indexPath.section)[distanceChoice]
                cell.switchLabel?.text = chosenOption["name"]
            } else {
                if distanceChoice == indexPath.row {
                    cell.accessoryType = .Checkmark
                }
                cell.switchLabel?.text = theOption["name"]
                // set based on the value
            }
            break
        case 3:
            if (contains(YelpClient.sharedInstance.categories, theOption["code"]!)) {
                cell.onSwitch.on = true
                switchStates[indexPath.row] = true;
            }
            break
        default:
            break
        }
        
        cell.delegate = self
        return cell
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        
        switch indexPath.section {
        case 0:
            dealSwitchState = value
            break
        case 3:
            switchStates[indexPath.row] = value
            break
        default:
            break
        }
    }
    
    func expandCollapseCell(expandCollapseCell: ExpandCollapseCell, didChangeValue value: Bool) {
        if (value == false) {
            return
        }
        categoriesCollapsed = !categoriesCollapsed
        tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: UITableViewRowAnimation.Automatic)
        //tableView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
