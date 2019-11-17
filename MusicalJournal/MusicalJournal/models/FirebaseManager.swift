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
    
    func add(journal: Journal) {
        
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
                journal.id = ref!.documentID
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
    
    func listen(id: String, completionHandler: @escaping (Bool, Journal?) -> ()) {
        db.collection("Journals").document(id).addSnapshotListener { documentSnapshot, error in
          guard let document = documentSnapshot else {
            print("Error fetching document: \(error!)")
            completionHandler(false, nil)
            return
          }
          guard let data = document.data() else {
            print("Document data was empty.")
            completionHandler(false, nil)
            return
          }
          //print("Current data: \(data)")
            completionHandler(true, Journal.init(title: data["title"] as! String, text: data["text"] as! String, id: data["id"] as! String))
        }
    }
    
    func listenToAll(completionHandler: @escaping (Bool, String?, [Journal]?) -> ()) {
        db.collection("Journals").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                completionHandler(false, nil, nil)
                return
            }
            snapshot.documentChanges.forEach { diff in
                let journal = Journal(
                    title: diff.document.data()["title"] as! String,
                    text: diff.document.data()["text"] as! String,
                    id: diff.document.data()["id"] as! String)
                
                
                if (diff.type == .added) {
                    //print("New Journal: \(diff.document.data())")
                    
                    _ = self.getJournals { (success, data) in
                        completionHandler(true,"added", data)
                    }
                }
                if (diff.type == .modified) {
                    //print("Modified Journal: \(diff.document.data())")
                    _ = self.getJournals { (success, data) in
                        completionHandler(true,"modified",data)
                    }
                    
                }
                if (diff.type == .removed) {
                    //print("Removed Journal: \(diff.document.data())")
                    _ = self.getJournals { (success, data) in
                        completionHandler(true,"removed",data)
                    }
                    
                }
            }
        }
    }
    
    func delete(id: String, completionHandler: @escaping (Bool, String) -> ()) {
        
        db.collection("Journals").document(id).delete() { err in
            if let err = err {
                completionHandler(false, err.localizedDescription)
            } else {
                completionHandler(true, "none")
            }
        }
    }
    
    
    func update(journal: Journal, field: String, completionHandler: @escaping (Bool, String) -> ()) {
        let id = journal.id
        var data: String = ""
        if field == "text" {
            data = journal.text
        } else if field == "title" {
            data = journal.title
        }
        
        
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


