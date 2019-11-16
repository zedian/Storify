//
//  DetailControllerViewController.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-16.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import UIKit

class DetailController: UIViewController, JournalListViewControllerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var spotifyView: UIView!
    
    var journal: Journal?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func journalListViewController(_ controller: JournalController, didSelectJournal: Journal) {
        self.journal = didSelectJournal
        textView.text = didSelectJournal.text
        titleLabel.text = didSelectJournal.title
    }

}
