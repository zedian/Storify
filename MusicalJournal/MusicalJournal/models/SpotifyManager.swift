//
//  SpotifyManager.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-16.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import Foundation

class SpotifyManager  {
    
    static let shared = SpotifyManager()
    
    // MARK: Variables
   let SpotifyClientID = "d0767a29c0c2495e98f7c344df060bc0"
   let SpotifyRedirectURL = URL(string: "musical-journal://spotify-login-callback")!
   
   lazy var configuration : SPTConfiguration = {
   let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
       // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
       // otherwise another app switch will be required
       configuration.playURI = "spotify:track:4uLU6hMCjMI75M1A2tKUQC"
      return configuration
  }()

   var accessToken: String = "key-access-token"

    var lastPlayerState: SPTAppRemotePlayerState?
   
   lazy var appRemote: SPTAppRemote = {
     let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
     return appRemote
   }()
    
    private init() {
        
    }
}
