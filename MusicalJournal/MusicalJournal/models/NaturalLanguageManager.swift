//
//  NaturalLanguageManager.swift
//  MusicalJournal
//
//  Created by Christian Pickett on 2019-11-16.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import Foundation

struct ResponseModel : Codable {
    var id : String
    var text : String
}

public class NaturalLanguageManager {
    
    public static let shared = NaturalLanguageManager()
    private init() {}
    
    let session = URLSession.shared
    let apiUrl = URL(string: "http://fa06a73c.ngrok.io")!
    
    func getSuggestions(data: String) -> Void {
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        
        let params = ["text":data]
        let jsonString = params.reduce("") { "\($0)\($1.0)=\($1.1)&" }
        let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false)!
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody  = jsonData
        
        
        let task = session.uploadTask(with: request, from: jsonData) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
                do {
                    let result = try JSONDecoder().decode([ResponseModel].self, from: data)
                    for item in result {
                        print(item.id, item.text)
                    }
                } catch {
                    print("Error : \(error.localizedDescription)")
                }
                
                
            }
            
            if error != nil {
                print("ERROR : \(error)")
            }
            
        }
        
        task.resume()
    }
}
