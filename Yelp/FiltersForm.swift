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
    
    var deals: UInt = 0
    var distance: String = "distance_auto"
    var sortMode: String = "sort_0"
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
        // shouldn't be doing this here
        deals = YelpClient.sharedInstance.deals != nil ? 1 : 0
        categories = YelpClient.sharedInstance.categories ?? []
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