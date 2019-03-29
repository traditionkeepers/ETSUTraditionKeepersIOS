//
//  ActivityCollectionViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/15/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit
import Firebase

class ActivityCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var rightBarItem: UIBarButtonItem!
    @IBOutlet weak var CategoryCollectionView: UICollectionView!
    
    @IBAction func EditPressed(_ sender: Any) {
        setEditing(!isEditing, animated: true)
        
        if isEditing {
            rightBarItem.title = "Save"
            rightBarItem.tintColor = .red
        } else {
            rightBarItem.title = "Edit"
            rightBarItem.tintColor = nil
        }
    }
    
    private let currentUser = User.currentUser
    private var selectedCategory: Category?
    
    var categories = Category.Categories {
        didSet {
            CategoryCollectionView?.reloadData()
        }
    }
    
    var categoryTitles: [String] {
        return categories.keys.sorted()
    }
    
    /// Gets all catagories in the database
    ///
    func FetchCategories() {
        Activity.db.collection("categories").getDocuments(completion: { (QuerySnapshot, err) in
            if let err = err {
                print("Error retreiving documents: \(err)")
            } else {
                self.categories.removeAll()
                for doc in QuerySnapshot!.documents {
                    let newCategory = Category(fromDoc: doc)
                    Category.Categories[newCategory.name] = newCategory
                }
                print(self.categories)
            }
        })
    }
    
    private let sectionInsets = UIEdgeInsets(top: 20.0,
                                             left: 20.0,
                                             bottom: 20.0,
                                             right: 20.0)
    private let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //navigationController?.setNavigationBarHidden(true, animated: false)
        FetchCategories()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "ShowCategoryDetail":
            if let vc = segue.destination as? CategoryViewController {
//                vc.selectedCategory = self.selectedCategory
            }
        default:
            break
        }
    }

}

// Mark: - Collection View Data Source
extension ActivityCollectionViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! ActivityCategoryCollectionViewCell
        if indexPath.item == 0 {
            cell.CategoryLabel.text = "All Activities"
        } else {
            cell.CategoryLabel.text = categoryTitles[indexPath.item - 1]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            if indexPath.item > 0 {
                let actionSheet = UIAlertController(title: "Options", message: "Please choose an option for \(categoryTitles[indexPath.item - 1])", preferredStyle: .actionSheet)
                let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    let prompt = UIAlertController(title: "Confirm Deletion?", message: "Are you sure you want to delete \(self.categoryTitles[indexPath.item])? This operation cannot be undone!", preferredStyle: .alert)
                    let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                        print("Item Deleted")
                    })
                    
                    prompt.addAction(cancelButton)
                    prompt.addAction(deleteButton)
                    self.navigationController!.present(prompt, animated: true, completion: nil)
                })
                let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                actionSheet.addAction(cancelButton)
                actionSheet.addAction(deleteButton)
                present(actionSheet, animated: true, completion: nil)
            }
        } else {
            if indexPath.item == 0 {
//                selectedCategory = "All Activities"
            } else {
//                selectedCategory = self.categories[indexPath.item - 1].name
            }
            performSegue(withIdentifier: "ShowCategoryDetail", sender: nil)
            
        }
    }
}

// Mark: - Collection View Flow Loayout Delegate
extension ActivityCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 2)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.bottom
        
    }
}
