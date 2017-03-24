//
//  DocPromptTableViewCell.swift
//  Dr.Text
//
//  Created by SoftSuave on 09/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class DocPromptTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var checkBoxLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
