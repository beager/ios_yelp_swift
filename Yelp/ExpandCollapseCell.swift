//
//  ExpandCollapseCell.swift
//  Yelp
//
//  Created by Bill Eager on 9/9/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol ExpandCollapseCellDelegate {
    optional func expandCollapseCell(expandCollapseCell: ExpandCollapseCell, didChangeValue value: Bool)
}

class ExpandCollapseCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: ExpandCollapseCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        println("selected")
        super.setSelected(selected, animated: animated)

        delegate?.expandCollapseCell?(self, didChangeValue: selected)
        // Configure the view for the selected state
    }
    
}