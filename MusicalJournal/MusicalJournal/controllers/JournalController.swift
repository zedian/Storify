//
//  JournalController.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-16.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import UIKit

class JournalController: UIViewController {
    
    @IBOutlet weak var spotifyButton: UIBarButtonItem!
    
    @IBOutlet weak var journalTable: UITableView! {
        didSet  {
            self.journalTable.delegate = self
            let nib = UINib(nibName: "StoryCell", bundle: nil)
            self.journalTable.register(nib, forCellReuseIdentifier: "StoryCell")
            self.journalTable.dataSource  = self
            
        }
    }
    
    override func viewDidLoad() {
        
    }

    @IBAction func goToSpotify(_ sender: UIButton) {
        self.performSegue(withIdentifier: "playSpotify", sender: self)
    }
}

extension JournalController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath)
        guard let storyCell = cell as? StoryCell else {return cell}
        
        return storyCell
    }
    
    
}
