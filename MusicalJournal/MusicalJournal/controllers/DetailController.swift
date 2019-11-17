//
//  DetailControllerViewController.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-16.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import UIKit


class DetailController: UIViewController, JournalListViewControllerDelegate {
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var textField: UITextField! {
        didSet{
            textField.delegate = self
            
        }
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }
    
    @IBOutlet weak var clearView: UIView!
    @IBOutlet weak var spotifyView: UIView!
    
    var mainVC: JournalController?
    var journal: Journal?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(clearInput))
          clearView.addGestureRecognizer(gr)
        self.view.bringSubviewToFront(clearView)
          clearView.isUserInteractionEnabled = true
          clearView.alpha = 0
//        // Do any additional setup after loading the view.
//        FirebaseManager.shared.listen(id: <#T##String#>) { (<#Bool#>, <#Journal?#>) in
//            <#code#>
//        }
    }
   
  
    func journalListViewController(_ controller: JournalController, didSelectJournal: Journal, indexPath: IndexPath, first: Bool) {
        self.mainVC = controller
        self.indexPath = indexPath
        self.journal = didSelectJournal
        textView.text = didSelectJournal.text
        textField.text = didSelectJournal.title
        self.textView.isEditable = true
        self.textField.isEnabled = true
        self.deleteButton.isHidden = false
        controller.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        if(first) {
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func clearInput() {
        clearView.alpha = 0
        self.view.endEditing(true)
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        guard let indexPath = indexPath else {return}
        mainVC?.journals.remove(at: indexPath.row)
        guard let id = journal?.id else {return}
        FirebaseManager.shared.delete(id: id) { (success, error) in
            
        }
        self.journal = nil
        self.textView.text = ""
        self.textView.isEditable = false
        self.textField.isEnabled = false
        self.indexPath = nil
        self.textField.text = ""
        self.mainVC?.tableView.reloadData()
        self.deleteButton.isHidden = true
    }
    
}

extension DetailController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
        clearView.alpha = 1
        self.view.bringSubviewToFront(clearView)
        self.view.bringSubviewToFront(textField)
        self.view.bringSubviewToFront(self.deleteButton)
    }
    func textViewDidChange(_ textView: UITextView) {
        
        guard let journal =  journal  else {return}
        journal.text = self.textView.text
        guard let indexPath = indexPath else {return}
        mainVC?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        FirebaseManager.shared.update(journal: journal, field: "text") { (success, error) in
            if(success) {
                
            } else {
                
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard let journal =  journal  else {return}
        journal.text = self.textView.text
        if textView.text.isEmpty {
            textView.text = "Write a story!"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension DetailController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let journal =  journal  else {return}
        if textField.text == "" {
            journal.title = "New Story"
        } else {
            if let text = textField.text {
                journal.title = text
            } else {
                journal.title = "New Story"
                
            }
            FirebaseManager.shared.update(journal: journal, field: "title") { (success, error) in
               if(success) {
                   
               } else {
                   
               }
            }
        }
        self.mainVC?.tableView.reloadData()
        guard let indexPath = indexPath else {return}
        mainVC?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.clearView.alpha = 1
         self.view.bringSubviewToFront(clearView)
         self.view.bringSubviewToFront(self.textView)
        self.view.bringSubviewToFront(self.deleteButton)
    }
    
    
}
