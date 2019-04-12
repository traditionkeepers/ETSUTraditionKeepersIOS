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

class DashboardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice!
    var frontCamera: AVCaptureDevice!
    var currentCamera: AVCaptureDevice!
    
    var photoOutput: AVCapturePhotoOutput!
    
    var camaraPreviewLayer: AVCaptureVideoPreviewLayer!
    
    private var topThree: [Tradition] = [] {
        didSet {
            TopThreeTable.reloadData()
        }
    }
    
    
    private var selectedIndex: Int!
    private var DateFormat = DateFormatter()
    
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
    
    /* @IBAction func cameraButton_TouchUpInside(_ sender: Any)  {
     let settings = AVCapturePhotoSettings()
     photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
     }
     
     extension ViewController: AVCapturePhotoCaptureDelegate {
     
     }*/
    
    func SetupView(_ animated: Bool = false) {
        usernameButton.setTitle("Welcome, \(User.current.first)", for: .normal)
        progressButton.setTitle(User.current.uid, for: .normal)
        if let selectionIndexPath = TopThreeTable.indexPathForSelectedRow {
            TopThreeTable.deselectRow(at: selectionIndexPath, animated: animated)
        }
        GetTopThree()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        SetupView(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
                vc.tradition = topThree[selectedIndex]
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
        
        let status = topThree[indexPath.row].submission.status
        switch status {
        case .none:
            cell.CompleteButton.setTitle(status.rawValue, for: UIControl.State.normal)
            cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU GOLD"), for: .normal)
            cell.CompleteButtonPressed = { (cell) in
                self.ShowAlertForRow(row: indexPath.row)
            }
        case .pending:
            cell.CompleteButton.setTitle(status.rawValue, for: UIControl.State.normal)
            cell.CompleteButton.setTitleColor(UIColor.init(named: "ETSU WHITE"), for: .normal)
            cell.CompleteButtonPressed = nil
        case .complete:
            let date = topThree[indexPath.row].submission.completion_date
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
    func ShowAlertForRow(row: Int) {
        print("Complete Button Pressed")
//        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
//        let devices = deviceDiscoverySession.devices
//
//        setupCaptureSession()
//        setupDevice()
//        if (devices.count > 0) {
//            setupInputOutput()
//            setupPreviewLayer()
//            startRunningCaptureSession()
//        }
        
        let alert = UIAlertController(title: "Complete Event", message: "Would you like to submit this activity for verification?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { (UIAlertAction) in
            self.topThree[row].submission.status = .pending
            self.topThree[row].submission.user_id = User.current.uid
            self.topThree[row].submission.activity = self.topThree[row].id ?? ""
            self.topThree[row].submission.completion_date = Date()
            self.UpdateDatabase(activity: self.topThree[row])
        }
        
        alert.addAction(cancel)
        alert.addAction(submit)
        self.present(alert, animated: true, completion: nil)
    }
    
    func UpdateDatabase(activity: Tradition) {
        if activity.id != nil {
            Firestore.firestore().collection("completed_activities").document().setData(activity.submissionDictionary) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Activity successfully added to database!")
                }
            }
        }
    }
    
    func GetTopThree() {
        var activities :[Tradition] = []
        Firestore.firestore().collection("traditions").limit(to: 3).getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                for doc in QuerySnapshot!.documents {
                    activities.append(Tradition(dictionary: doc.data(), id: doc.documentID)!)
                }
                self.topThree = activities
            }
        })
    }
}
