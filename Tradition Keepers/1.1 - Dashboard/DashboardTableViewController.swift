//
//  TableViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/14/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MobileCoreServices

class DashboardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    /*  Vars for AVFoundation Implementation
     var captureSession = AVCaptureSession()
     var backCamera: AVCaptureDevice!
     var frontCamera: AVCaptureDevice!
     var currentCamera: AVCaptureDevice!
     var photoOutput: AVCapturePhotoOutput!
     var camaraPreviewLayer: AVCaptureVideoPreviewLayer!
     */
    
    private var submissionImage: UIImage!
    
    
    private var topThree: [Activity] = [] {
        didSet {
            TopThreeTable.reloadData()
        }
    }
    
    
    private var selectedIndex: Int!
    private var DateFormat = DateFormatter()
    private var selectedActivity: Activity!
    
    @IBOutlet weak var TopThreeTable: UITableView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DateFormat.dateStyle = .short
        DateFormat.timeStyle = .none
        DateFormat.locale = Locale(identifier: "en_US")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    /*
     func setupCaptureSession() {
     captureSession.sessionPreset = AVCaptureSession.Preset.photo
     }
     
     func setupDevice() {
     let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
     let devices = deviceDiscoverySession.devices
     
     for device in devices {
     if device.position == AVCaptureDevice.Position.back {
     backCamera = device
     } else if device.position == AVCaptureDevice.Position.front {
     frontCamera = device
     }
     }
     currentCamera = backCamera
     }
     
     func setupInputOutput() {
     do {
     let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
     captureSession.addInput(captureDeviceInput)
     photoOutput = AVCapturePhotoOutput()
     photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
     captureSession.addOutput(photoOutput)
     } catch {
     print(error)
     return
     }
     }
     
     func setupPreviewLayer() {
     camaraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
     camaraPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
     camaraPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
     camaraPreviewLayer.frame = self.view.frame
     self.view.layer.insertSublayer(camaraPreviewLayer, at: 0)
     
     }
     
     func startRunningCaptureSession() {
     captureSession.startRunning()
     }
     
     
     
     func takePicture() {
     let picker = UIImagePickerController()
     picker.sourceType = .camera
     picker.mediaTypes = [kUTTypeImage as String]
     picker.allowsEditing = true
     picker.delegate = self
     present(picker, animated: true)
     }
     */
    func ShowAlertForRow(row: Int) {
        print("Complete Button Pressed")
        getImage()
        //Submit.WithCamera(self)
    }
        func getImage () {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Choose a source", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func promptForCompletion(activity: Activity) {
        
        let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
        
        
        let imageView = UIImageView(frame: CGRect(x: 10, y: 82, width: 250, height: 187.5))
        imageView.image = submissionImage
        alert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        let width = NSLayoutConstraint(item: alert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        alert.view.addConstraint(height)
        alert.view.addConstraint(width)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            self.selectedActivity.completion.status = .pending
            self.selectedActivity.completion.user_id = User.uid
            self.selectedActivity.completion.activity_ref = Activity.db.document("activities/\(self.selectedActivity.id ?? "")")
            self.selectedActivity.completion.date = Date()
            self.UpdateDatabase(activity: self.selectedActivity)
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let imageData = image.pngData()!
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 300] as CFDictionary
        let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
        let thumbnail = UIImage(cgImage: imageReference)
        submissionImage = image
        picker.dismiss(animated: true, completion: nil)
        
        promptForCompletion(activity: selectedActivity)
    }
    
    func SetupView(_ animated: Bool = false) {
        usernameButton.setTitle("Welcome, \(User.currentUser.data.first)", for: .normal)
        progressButton.setTitle(User.uid, for: .normal)
        if let selectionIndexPath = TopThreeTable.indexPathForSelectedRow {
            TopThreeTable.deselectRow(at: selectionIndexPath, animated: animated)
        }
        GetTopThree()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SetupView(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func pressedUserButton(_ sender: Any) {
        performSegue(withIdentifier: "ShowUserDetail", sender: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "ShowActivityDetail":
            if let vc = segue.destination as? ActivityDetailViewController {
                vc.selectedActivity = topThree[selectedIndex]
            }
        default:
            break
        }
    }
}

// MARK: - Table view data source
extension DashboardTableViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return topThree.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityTableViewCell
        cell.NameLabel.text = topThree[indexPath.row].title
        cell.SecondaryLabel.text = topThree[indexPath.row].instruction
        
        let status = topThree[indexPath.row].completion.status
        switch status {
        case .none:
            cell.CompleteButton.setTitle(status.rawValue, for: UIControl.State.normal)
            cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU GOLD"), for: .normal)
            cell.CompleteButtonPressed = { (cell) in
                self.selectedActivity = self.topThree[indexPath.row]
                self.ShowAlertForRow(row: indexPath.row)
            }
        case .pending:
            cell.CompleteButton.setTitle(status.rawValue, for: UIControl.State.normal)
            cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU WHITE"), for: .normal)
            cell.CompleteButtonPressed = nil
        case .verified:
            let date = topThree[indexPath.row].completion.date
            cell.CompleteButton.setTitle(DateFormat.string(from: date), for: .normal)
            cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU WHITE"), for: .normal)
            cell.CompleteButtonPressed = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "ShowActivityDetail", sender: nil)
    }
}


// MARK: Firebase
extension DashboardTableViewController {
    
    func UpdateDatabase(activity: Activity) {
        if activity.id != nil {
            Activity.db.collection("completed_activities").document().setData(activity.Completed) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
    }
    
    func GetTopThree() {
        var activities :[Activity] = []
        Activity.db.collection("activities").limit(to: 3).getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    activities.append(Activity(fromDoc: doc))
                }
                self.topThree = activities
            }
        })
    }
}

