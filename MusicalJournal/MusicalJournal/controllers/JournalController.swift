//
//  JournalController.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-16.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import UIKit

protocol JournalListViewControllerDelegate {
    func journalListViewController(_ controller: JournalController, didSelectJournal: Journal)
}

class JournalController: UITableViewController {
    
    var journals: [Journal] = [
        Journal(title: "Hello", text: "WHAT"),
        Journal(title: "What", text: "WHAT"),
        Journal(title: "The", text: "WHAT"),
        Journal(title: "Fuck", text: "WHAT")
    ]
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        let nib = UINib(nibName: "JournalCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "JournalCell")
        self.tableView.reloadData()
        self.tableView.dataSource = self
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journals.count
    }
    
    override  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalCell", for: indexPath)
        guard let journalCell = cell as? JournalCell else {return cell}
        
        return journalCell
    }
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedJournal  = journals[indexPath.row]
        
            
        guard let detail = self.splitViewController?.children.first(where: { (vc) -> Bool in
            if let vc = vc as?  DetailController {
                return  true
            }
            return false
        }) as? DetailController else {return}
        detail.journalListViewController(self, didSelectJournal: selectedJournal)
        self.splitViewController?.showDetailViewController(detail, sender: self)
        
    }
    
    override  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
  
    
}
