//
//  DYFStoreTableViewCell.swift
//
//  Created by chenxing on 2016/11/28. ( https://github.com/chenxing640/DYFStore )
//  Copyright © 2016 chenxing. All rights reserved.
//

import UIKit

class DYFStoreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var localePriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
