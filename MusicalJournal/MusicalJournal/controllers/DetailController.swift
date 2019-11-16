//
//  DetailControllerViewController.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-16.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import UIKit


class DetailController: UIViewController, JournalListViewControllerDelegate {
    
    
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
        // Do any additional setup after loading the view.
    }
   
  
    func journalListViewController(_ controller: JournalController, didSelectJournal: Journal, indexPath: IndexPath, first: Bool) {
        self.mainVC = controller
        self.indexPath = indexPath
        self.journal = didSelectJournal
        textView.text = didSelectJournal.text
        textField.text = didSelectJournal.title
        controller.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        if(first) {
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func clearInput() {
        clearView.alpha = 0
        self.view.endEditing(true)
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
    }
    func textViewDidChange(_ textView: UITextView) {
        
        guard let journal =  journal  else {return}
        journal.text = self.textView.text
         guard let indexPath = indexPath else {return}
        mainVC?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
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
        }
        self.mainVC?.tableView.reloadData()
        guard let indexPath = indexPath else {return}
        mainVC?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
         clearView.alpha = 1
         self.view.bringSubviewToFront(clearView)
         self.view.bringSubviewToFront(self.textView)
    }
    
    
}
