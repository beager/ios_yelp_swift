//
//  FormFiltersViewController.swift
//  Yelp
//
//  Created by Bill Eager on 9/7/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FormFiltersViewControllerDelegate {
    optional func formFiltersViewController(formFiltersViewController: FormFiltersViewController, didUpdateFilters filters: FiltersForm)
}

class FormFiltersViewController: FXFormViewController {

    @IBAction func onCancelButton(sender: AnyObject) {
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        
    }
    
    weak var delegate: FormFiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func awakeFromNib() {
        formController.form = FiltersForm()
        
        //formController.form.deals = YelpClient.sharedInstance.deals?
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func submitRegistrationForm(cell: FXFormFieldCellProtocol) {
        
        //we can lookup the form from the cell if we want, like this:
        let form = cell.field.form as! FiltersForm
        
        delegate?.formFiltersViewController?(self, didUpdateFilters: form)
        dismissViewControllerAnimated(true, completion: nil)
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
