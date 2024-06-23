//
//  SKStoreTableViewCell.swift
//
//  Created by Tenfay on 2016/11/28.
//  Copyright © 2016 Tenfay. All rights reserved.
//

import UIKit

class SKStoreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var localePriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
