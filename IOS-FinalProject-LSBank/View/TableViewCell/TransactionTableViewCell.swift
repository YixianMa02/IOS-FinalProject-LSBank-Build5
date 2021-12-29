//
//  TransactionTableViewCell.swift
//  IOS-FinalProject-LSBank
//
//  Created by english on 2021-11-25.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionDate: UILabel!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var amountTransfered: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var arrowImageType: UIImageView!
    
    static let identifier = "TransactionTableViewCell"
    
    // This func is to call the nib we defined as custom UI for our cell
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // This function wil handle the data inside our XIB/NIB file (cell/row)
    public func setCellContent(accountHolder : String, dateTime : String, amount : Double, credit : Bool, messages : String) {
        
        if credit {
            accountName.text = "FROM \(accountHolder.uppercased())"
            arrowImageType.image = UIImage(systemName: "arrow.down")
            arrowImageType.tintColor = .green;
            
            
        } else {
            accountName.text = "TO \(accountHolder.uppercased())"
            arrowImageType.image = UIImage(systemName: "arrow.up")
            arrowImageType.tintColor = .red;
            
        }
        
        transactionDate.text = dateTime
        amountTransfered.text = amount.formatAsCurrency() // format to 1,000,000.00
        message.text = messages
        
        if messages.count == 0 {
            message.isHidden = true
        }
        else {
            message.isHidden = false
        }
        
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
