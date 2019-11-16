//
//  Firebase.swift
//  MusicalJournal
//
//  Created by Christian Pickett on 2019-11-16.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import Foundation
import Firebase



class FirebaseManager {
    
    let db = Firestore.firestore()
    
    static let shared = FirebaseManager()
    private init(){}
    
    func add(journal: Journal) -> DocumentReference? {
        
        var ref: DocumentReference? = nil
        
        ref = db.collection("Journals").addDocument(data: [
            "title" : journal.title,
            "text" : journal.text
        ]) { err in
            if let err = err {
                print("Error add document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
            
        }
        
        return ref
    }
    
    func getJournals(completionhandler: @escaping (Bool, [Journal]) -> ()) {
        
        var journals: [Journal] = []
        
        db.collection("Journals").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionhandler(false, [])
            } else {
                for document in querySnapshot!.documents {

                    journals.append(Journal.init(title: document.data()["title"] as! String,
                                                 text: document.data()["text"] as! String))
                }
                completionhandler(true, journals)
            }
        }

        
    }
    
    
    
    
}


