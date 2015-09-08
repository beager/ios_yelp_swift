//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FormFiltersViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var businesses: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        

//        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
//            self.businesses = businesses
//            
//            for business in businesses {
//                println(business.name!)
//                println(business.address!)
//            }
//        })
        
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                println(business.name!)
                println(business.address!)
            }
            
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FormFiltersViewController
        filtersViewController.delegate = self
    }
    
    func formFiltersViewController(formFiltersViewController: FormFiltersViewController, didUpdateFilters filters: FiltersForm) {
        
        if filters.sortMode != "" {
            var translatedSortMode: YelpSortMode!
            switch filters.sortMode {
                case "sort_0":
                    translatedSortMode = .BestMatched
                case "sort_1":
                    translatedSortMode = .Distance
                case "sort_2":
                    translatedSortMode = .HighestRated
                default:
                    translatedSortMode = .BestMatched
            }
            YelpClient.sharedInstance.sort = translatedSortMode
        }
        
        YelpClient.sharedInstance.deals = filters.deals > 0 ? true : false
        
        if filters.categories?.count > 0 {
            YelpClient.sharedInstance.categories = filters.categories as! [String]
        } else {
            YelpClient.sharedInstance.categories = []
        }
        
        var translatedDistance: Int!
        switch filters.distance {
            case "distance_0_3":
                translatedDistance = 483
            case "distance_1":
                translatedDistance = 1609
            case "distance_5":
                translatedDistance = 8047
            case "distance_20":
                translatedDistance = 32187
            case "distance_auto":
                translatedDistance = -1
        default:
                translatedDistance = -1
        }
        
        if translatedDistance > 0 {
            YelpClient.sharedInstance.radius = translatedDistance
        } else {
            YelpClient.sharedInstance.radius = nil
        }
        YelpClient.sharedInstance.search { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
}
