//
//  AboutViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/24/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet var WebButton: UIButton!
    @IBOutlet var FacebookButton: UIButton!
    @IBOutlet var TwitterButton: UIButton!
    @IBOutlet var InstagramButton: UIButton!
    @IBOutlet var MailButton: UIButton!
    
    @IBAction func SocialButtonPressed(sender: UIButton) {
        var url = ("", "")
        if sender == WebButton {
            url = ("", "www.etsualumni.org")
        } else if sender == FacebookButton {
            url = ("fb://profile/762223030522199", "https://www.facebook.com/ETSUTraditionKeepers/")
        } else if sender == TwitterButton {
            url = ("", "https://twitter.com/etsutradkeepers")
        } else if sender == InstagramButton {
            url = ("instagram://user?username=etsu_traditionkeepers", "https://www.instagram.com/etsu_traditionkeepers")
        } else if sender == MailButton {
            
        } else {
            return
        }
        
        if url.0.isEmpty {
            UIApplication.shared.open(URL(string: url.1)!, options: [:], completionHandler: { (success) in
                print("Open \(url): \(success)")
            })
        } else {
            UIApplication.shared.open(URL(string: url.0)!, options: [:]) { (success) in
                print("Open \(url): \(success)")
                if !success {
                    UIApplication.shared.open(URL(string: url.1)!, options: [:], completionHandler: { (success) in
                        print("Open \(url): \(success)")
                    })
                }
            }
        }
    }
    @IBAction func DonePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareView()
    }
    
    private func prepareView() {
        WebButton.setIcon(icon: .ionicons(.iosWorld), iconSize: 50, color: UIColor(named: "ETSU GOLD")!, backgroundColor: .clear, forState: .normal)
        FacebookButton.setIcon(icon: .ionicons(.socialFacebook), iconSize: 50, color: UIColor(named: "ETSU GOLD")!, backgroundColor: .clear, forState: .normal)
        TwitterButton.setIcon(icon: .ionicons(.socialTwitter), iconSize: 50, color: UIColor(named: "ETSU GOLD")!, backgroundColor: .clear, forState: .normal)
        InstagramButton.setIcon(icon: .ionicons(.socialInstagram), iconSize: 50, color: UIColor(named: "ETSU GOLD")!, backgroundColor: .clear, forState: .normal)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
