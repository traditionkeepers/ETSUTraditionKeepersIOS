//
//  MainEventTableViewCell.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/9/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class MainEventTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventIcon: UIImageView!
    @IBOutlet weak var eventCompleted: UILabel!
    
    func update(with event: Event, isCompleted: Bool) {
        eventName.text = event.name
        eventDescription.text = event.description
        
        let df = DateFormatter()
        let tf = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        tf.dateStyle = .none
        tf.timeStyle = .short
        
        eventDate.text = df.string(from: event.dateTime)
        eventTime.text = tf.string(from: event.dateTime)
        
        eventCompleted.isHidden =  !isCompleted
    }
}
