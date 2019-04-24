//
//  InstructionsCollectionViewController.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/24/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import UIKit

private let reuseIdentifier = "InstructionCell"

class InstructionsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var InstructionsCollection: UICollectionView!
    @IBOutlet var PageControl: UIPageControl!
    
    private var pages: [Instruction]  = [
            Instruction(title: "Welcome",
                        description: "Welcome to ETSU. We are a university rich in history and traditions. In this application, we have compiled a list of traditions we recommend all ETSU students take part in before graduation to get the full ETSU experience!"
                ),
            Instruction(title: "About", description: "The ETSU Tradition Keepers aim to transform how students view themselves. Students today are the alumni of tomorrow, which not only enforces the bond between student and institution but also enhances an affinity for their alma mater after graduation.")
        ]
    @IBAction func SkipButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Contact", sender: nil)
    }
    
    @IBAction func NextButtonPressed(_ sender: Any) {
        if PageControl.currentPage == pages.count - 1 {
            performSegue(withIdentifier: "Contact", sender: nil)
        } else {
            let indexPath = IndexPath(item: PageControl.currentPage + 1, section: 0)
            InstructionsCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            PageControl.currentPage += 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        

        // Do any additional setup after loading the view.
        prepareView()
    }
    
    private func prepareView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        self.InstructionsCollection.collectionViewLayout = layout
        self.InstructionsCollection.isPagingEnabled = true
        
        PageControl.numberOfPages = pages.count
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InstructionCollectionViewCell
    
        // Configure the cell
        let page = pages[indexPath.item]
        cell.TitleTextField.text = page.title
        cell.DescriptionTextView.text = page.description
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / view.frame.width)
        PageControl.currentPage = pageNumber
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
