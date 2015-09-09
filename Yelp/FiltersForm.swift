//
//  RegistrationForm.swift
//  SwiftExample
//
//  Created by Nick Lockwood on 29/09/2014.
//  Copyright (c) 2014 Nick Lockwood. All rights reserved.
//

import UIKit

class CustomFormValueTransformer: NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if (value == nil) {
            return nil
        }
        let value = value as! String
        
        for (key, dicts) in yelpFormInfo {
            for dict in dicts {
                if dict["code"] == value {
                    return dict["name"]
                }
            }
        }

        return value
    }
}

class FiltersForm: NSObject, FXForm {
    
    var deals: AnyObject?
    var distance: String?
    var sortMode: String?
    var categories: NSArray?
    
    func keysForField(field: String) -> [String]! {
        for (category, dicts) in yelpFormInfo {
            if category == field {
                var output = [String]()
                for dict in dicts {
                    output.append(dict["code"]!)
                }
                return output
            }
        }
        return []
    }
    
    func fields() -> [AnyObject]! {
        // This is most definitely an anti-pattern. Hooking into the global shared instance at this point to set form parameters isn't good. This should instead be sending into the FXForm through the view controller chain etc. I just haven't looked into FXForm enough to know how to pass stuff in, so we're doing it this way.
        deals = YelpClient.sharedInstance.deals
        categories = YelpClient.sharedInstance.categories
        sortMode = YelpClient.sharedInstance.sort
        distance = YelpClient.sharedInstance.radius
        return [
            [FXFormFieldKey: "deals", FXFormFieldTitle: "Offering a deal", FXFormFieldType: FXFormFieldTypeBoolean],

            [
                FXFormFieldKey: "distance",
                FXFormFieldTitle: "Distance",
                FXFormFieldOptions: keysForField("distance"),
                FXFormFieldValueTransformer: CustomFormValueTransformer()
            ],
            
            [
                FXFormFieldKey: "sortMode",
                FXFormFieldTitle: "Sort by",
                FXFormFieldOptions: keysForField("sort"),
                FXFormFieldValueTransformer: CustomFormValueTransformer()
            ],

            [
                FXFormFieldKey: "categories",
                FXFormFieldTitle: "Categories",
                FXFormFieldOptions: keysForField("categories"),
                FXFormFieldValueTransformer: CustomFormValueTransformer()
            ],
            [FXFormFieldTitle: "Submit", FXFormFieldHeader: "", FXFormFieldAction: "submitRegistrationForm:"]
        ]
    }
}