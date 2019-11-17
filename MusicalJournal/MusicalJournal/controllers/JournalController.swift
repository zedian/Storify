//
//  JournalController.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-16.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import UIKit

protocol JournalListViewControllerDelegate {
    func journalListViewController(_ controller: JournalController, didSelectJournal: Journal, indexPath: IndexPath, first: Bool)
}

class JournalController: UITableViewController {
    
    var journals: [Journal] = []
    var detail: DetailController?
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        let nib = UINib(nibName: "JournalCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "JournalCell")
        self.tableView.reloadData()
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor(red: 26/255.0, green: 26/255.0, blue: 26/255.0, alpha: 1)
        self.tableView.separatorStyle = .none
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 21)!]
        navigationController?.navigationBar.barTintColor = UIColor(red: 14/255.0, green: 14/255.0, blue: 14/255.0, alpha: 1)
        
        FirebaseManager.shared.getJournals { (success, journals) in
           if(success) {
                if journals.count > 0 {
                    self.journals = journals
                    self.tableView.reloadData()
                    guard let detail = self.detail?.journalListViewController(self, didSelectJournal: journals[0], indexPath: IndexPath(row: 0, section: 0), first: false) else {return}
                } else {
                    self.addJournal()
                }
           } else {
                
           }
       }

        guard let detail = self.splitViewController?.children.first(where: { (vc) -> Bool in
               if let vc = vc as?  DetailController {
                   return  true
               }
               return false
        }) as? DetailController else {return}
        self.detail = detail
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journals.count
    }
    
    override  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalCell", for: indexPath)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 40/255.0, green: 40/255.0, blue: 40/255.0, alpha: 1)
        cell.selectedBackgroundView = bgColorView
        guard let journalCell = cell as? JournalCell else {return cell}
        
        journalCell.titleLabel.text = journals[indexPath.row].title
        
        return journalCell
    }
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedJournal  = journals[indexPath.row]
        guard let detail = detail else {return}
        detail.journalListViewController(self, didSelectJournal: selectedJournal, indexPath: indexPath, first: false)
        self.splitViewController?.showDetailViewController(detail, sender: self)
    }
    
    override  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
  
    @IBAction func addToTable(_ sender: UIButton) {
        addJournal()
    }
    
    func addJournal() {
        let newJournal = Journal(title: "New Story", text: "Write a story!")
          journals.insert(newJournal, at: 0)
          FirebaseManager.shared.add(journal: newJournal)
          self.tableView.reloadData()
          guard let detail = detail else {return}
          detail.journalListViewController(self, didSelectJournal: journals[0], indexPath: IndexPath(row: 0, section: 0), first: false)
    }
    
}

