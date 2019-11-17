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
    
    func getSuggestions(data: String, completionHandler: @escaping (Bool, [String: String]?) -> ()) {
        
        let apiUrl = URL(string: "https://d3f62cb6.ngrok.io")!
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        
        let params = ["text":data]
        let jsonString = params.reduce("") { "\($0)\($1.0)=\($1.1)&" }
        print(jsonString)
        let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false)!
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody  = jsonData
            
        let task = session.uploadTask(with: request, from: jsonData) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }

           if let error = error {
            
                print("ERROR : \(error)")
            } else {
                guard let data = data else {
                    print("Error")
                    return
                }
                do {
                   let json = try JSONSerialization.jsonObject(with: data, options: [])
                      if let object = json as? [String: String] {
                          // json is a dictionary
                          completionHandler(true, object)
                      } else if let object = json as? [Any] {
                          // json is an array
                          print(object)
                        completionHandler(false, nil)
                      } else {
                          print("JSON is invalid")
                        completionHandler(false, nil)
                      }
               } catch {
                   print("ERROR : \(error)")
                completionHandler(false, nil)
               }
            }
        }
        
        
        
        task.resume()
    }
    
    func getSpotifyAlbum(data: String, completionHandler: @escaping (Bool, [String: String]?) -> ()) {
        let apiUrl = URL(string: "http://56b82ec3.ngrok.io")!
        
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

           if let error = error {
            
                print("ERROR : \(error)")
            } else {
                guard let data = data else {
                    print("Error")
                    return
                }
                do {
                   let json = try JSONSerialization.jsonObject(with: data, options: [])
                      if let object = json as? [String: String] {
                          // json is a dictionary
                          completionHandler(true, object)
                      } else if let object = json as? [Any] {
                          // json is an array
                          print(object)
                        completionHandler(false, nil)
                      } else {
                          print("JSON is invalid")
                        completionHandler(false, nil)
                      }
               } catch {
                   print("ERROR : \(error)")
                completionHandler(false, nil)
               }
            }
        }
        task.resume()
        
    }
}
