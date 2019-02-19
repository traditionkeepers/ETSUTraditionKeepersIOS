//
//  LoginViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 2/9/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var store: PersistContainer!
    var currentUser: User!
    var emailPredicate: NSPredicate?
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let enteredEmail = emailField.text!
        emailPredicate = NSPredicate(format: "email == %@", enteredEmail)
        if loadUser(email: enteredEmail) {
            performSegue(withIdentifier: "login", sender: nil)
        } else {
            performSegue(withIdentifier: "newUser", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        store = PersistContainer(name: "Tradition_Keepers")
        store.container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    // MARK: - Navigation
    
    func loadUser(email:String) -> Bool {
        let request = User.createFetchRequest()
        request.predicate = emailPredicate
        
        do {
            let users: [User] = try store.context.fetch(request)
            print("Num:", users.count)
            if users.count == 0 {
                currentUser = User(context: store.context)
                currentUser.email = email
                store.saveContext()
                return false
            } else {
                currentUser = users[0]
                return true
            }
        } catch {
            print("Fetch failed")
            return false
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
                case "login":
                    if let vc = segue.destination as? NavTabBarController {
                        vc.currentUser = currentUser
                        vc.store = self.store
                }
                case "newUser":
                    if let vc = segue.destination as? UINavigationController {
                        vc.currentUser = currentUser
                        vc.store = self.store
                }
                
                default: break
            }
        }
    }

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
}
