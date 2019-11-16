//
//  Journal.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-16.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import Foundation

class Journal {
    var text: String
    var title: String
    var id: String
    
    init(title: String,  text: String, id: String = "nil") {
        self.text  = text
        self.title = title
        self.id = id
    }
}
