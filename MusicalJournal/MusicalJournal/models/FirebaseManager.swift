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
            "text" : journal.text,
            "id" : "nil"
        ]) { err in
            if let err = err {
                print("Error add document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                
                // Update id
                let doc = self.db.collection("Journals").document(ref!.documentID)

                doc.updateData([
                    "id": ref!.documentID
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
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
                                                 text: document.data()["text"] as! String,
                                    id: document.data()["id"] as! String))
                }
                completionhandler(true, journals)
            }
        }

        
    }
    
    func delete(id: String, completionHandler: @escaping (Bool, String) -> ()) {
        
        db.collection("Journals").document(id).delete() { err in
            if let err = err {
                completionHandler(false, err as! String)
            } else {
                completionHandler(true, "none")
            }
        }
    }
    
    
    func update(id: String, field: String, data: String, completionHandler: @escaping (Bool, String) -> ()) {
        
        let doc = self.db.collection("Journals").document(id)

        doc.updateData([
            field : data
        ]) { err in
            if let err = err {
                completionHandler(false, err as! String)
                print("Error updating document: \(err)")
            } else {
                completionHandler(true, "none")
            }
        }
    }
    
    
    
    
}


