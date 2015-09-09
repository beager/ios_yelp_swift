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

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {


    @IBOutlet weak var tableView: UITableView!
    
    var categories: [[String:String]]!
    var switchStates = [Int:Bool]()
    
    weak var delegate: FiltersViewControllerDelegate?

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        categories = yelpFormInfo["categories"]!

        // Do any additional setup after loading the view.
        tableView.reloadData()
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
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
        
        cell.switchLabel.text = categories[indexPath.row]["name"]
        var code = categories[indexPath.row]["code"]

        cell.delegate = self
        //cell.onSwitch.on = switchStates[indexPath.row] ?? false
        
        if YelpClient.sharedInstance.categories != nil {
            var isSelected: Bool = contains(YelpClient.sharedInstance.categories!, code!)
            cell.onSwitch.on = isSelected
            switchStates[indexPath.row] = isSelected
        } else {
            cell.onSwitch.on = false
            switchStates[indexPath.row] = false
        }
        
        return cell
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        
        println("didChangeValue")
        
        switchStates[indexPath.row] = value
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
