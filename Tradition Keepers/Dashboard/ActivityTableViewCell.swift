//
//  ActivityTableViewCell.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var AvtivityImage: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var CompleteButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func CompleteActivity(_ sender: Any) {
        
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        self.picker.showsCameraControls = NO;
        self.picker.navigationBarHidden = YES;
        self.picker.toolbarHidden = YES;
        self.picker.wantsFullScreenLayout = YES;
        
        // Insert the overlay
        self.overlay = [[OverlayViewController alloc] initWithNibName:@"Overlay" bundle:nil];
        self.overlay.pickerReference = self.picker;
        self.picker.cameraOverlayView = self.overlay.view;
        self.picker.delegate = self.overlay;
        
        [self presentModalViewController:self.picker animated: true];
    }
}
