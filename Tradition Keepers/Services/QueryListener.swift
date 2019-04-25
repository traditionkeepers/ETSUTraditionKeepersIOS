//
//  FireBaseExtension.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 4/25/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//

import Firebase

class QueryListener<T: DocumentSerializable> {
    var addedData: [T] = []
    var modifiedData: [T] = []
    var removedData: [T] = []
    var documents: [DocumentSnapshot] = []
    
    var completion: ((Error) -> ()) = {error in
        print(error)
    }

    private var db: Firestore {
        return Firestore.firestore()
    }
    private var ref: CollectionReference
    
    private var listener: ListenerRegistration?
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery(completion: completion)
            }
        }
    }
    
    init(ref: String) {
        self.ref = db.collection(ref)
    }
    
    func observeQuery(completion: (Error) -> ()) {
        guard let query = query else { return }
        stopObserving()
        
        // Display data from Firestore, part one
        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            
            self.addedData.removeAll()
            self.modifiedData.removeAll()
            self.removedData.removeAll()
            
            snapshot.documentChanges.forEach({ (diff) in
                switch diff.type {
                case .added:
                    print("Added")
                    self.addedData.append(T(dictionary: diff.document.data(), id: diff.document.documentID)!)
                case .modified:
                    print("Modified")
                    self.modifiedData.append(T(dictionary: diff.document.data(), id: diff.document.documentID)!)
                case .removed:
                    print("Removed")
                    self.removedData.append(T(dictionary: diff.document.data(), id: diff.document.documentID)!)
                default:
                    print("Unable to initialize type \(T.self) with dictionary \(diff.document.data())")
                }
                self.documents = snapshot.documents
            })
        }
    }
    
    func stopObserving() {
        listener?.remove()
    }
    
    private func baseQuery() -> Query {
        return ref
    }
}
