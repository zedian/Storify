//
//  ViewController.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-15.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import UIKit

class SpotifyController: UIViewController {
    
    
    // MARK: - Subviews
    @IBOutlet weak var connectButton: UIButton! {
        didSet {
            connectButton.backgroundColor = UIColor(red:(29.0 / 255.0), green:(185.0 / 255.0), blue:(84.0 / 255.0), alpha:1.0)
            connectButton.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
            let title = NSAttributedString(string: "CONNECT", attributes: [
                .font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .heavy),
                .foregroundColor: UIColor.white,
                .kern: 2.0
            ])
            connectButton.setAttributedTitle(title, for: .normal)
        }
    }

    @IBOutlet weak var disconnectButton: UIButton! {
        didSet {
            disconnectButton.backgroundColor = UIColor(red:(29.0 / 255.0), green:(185.0 / 255.0), blue:(84.0 / 255.0), alpha:1.0)
                     disconnectButton.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
                     let title = NSAttributedString(string: "DISCONNECT", attributes: [
                         .font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .heavy),
                         .foregroundColor: UIColor.white,
                         .kern: 2.0
                     ])
                     disconnectButton.setAttributedTitle(title, for: .normal)
        }
    }
    @IBOutlet weak var pauseAndPlayButton: UIButton! {
        didSet {
            pauseAndPlayButton.addTarget(self, action: #selector(didTapPauseOrPlay), for: .touchUpInside)
        }
    }
    

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFit
        }
    }

    @IBOutlet weak var trackLabel: UILabel! {
        didSet {
            trackLabel.textAlignment = .center
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SpotifyManager.shared.appRemote.delegate = self

        connectButton.addTarget(self, action: #selector(didTapConnect(_:)), for: .touchUpInside)
        updateViewBasedOnConnected()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.connectButton.layer.cornerRadius = self.connectButton.frame.height / 2
    }

    func update(playerState: SPTAppRemotePlayerState) {
        if SpotifyManager.shared.lastPlayerState?.track.uri != playerState.track.uri {
            fetchArtwork(for: playerState.track)
        }
        SpotifyManager.shared.lastPlayerState = playerState
        trackLabel.text = playerState.track.name
        
        if playerState.isPaused {
            pauseAndPlayButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            pauseAndPlayButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }

    func updateViewBasedOnConnected() {
        
        if (SpotifyManager.shared.appRemote.isConnected) {
                       guard let detail = parent as? DetailController else {return}
                       detail.spotifyView.layoutIfNeeded()
            DispatchQueue.main.async {
                 UIView.animate(withDuration: 2.0) {
                       print("Updated")
                    guard let detail = self.parent as? DetailController else {return}
                    detail.spotifyView.layoutIfNeeded()
                         self.disconnectButton.alpha = 0
                            self.connectButton.alpha = 1
                            self.imageView.alpha = 0
                            self.trackLabel.alpha = 0
                            self.pauseAndPlayButton.alpha = 0
                           detail.spotifyView.layoutIfNeeded()
                   }
            }
               
                   } else {
            DispatchQueue.main.async {
                guard let detail = self.parent as? DetailController else {return}
                detail.spotifyView.layoutIfNeeded()
                  UIView.animate(withDuration: 2.0) {
                    
                    
                      self.disconnectButton.alpha = 0
                      self.connectButton.alpha = 1
                      self.imageView.alpha = 0
                      self.trackLabel.alpha = 0
                      self.pauseAndPlayButton.alpha = 0
                   self.view.bringSubviewToFront(self.disconnectButton)
                   self.view.bringSubviewToFront(self.connectButton)
                      self.view.bringSubviewToFront(self.imageView)
                      self.view.bringSubviewToFront(self.trackLabel)
                      self.view.bringSubviewToFront(self.pauseAndPlayButton)
                      detail.spotifyView.layoutIfNeeded()
                        
                  }
            }
              
                
        }
       
    }

    func fetchArtwork(for track:SPTAppRemoteTrack) {
        SpotifyManager.shared.appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.imageView.image = image
            }
        })
    }

    func fetchPlayerState() {
        SpotifyManager.shared.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        })
    }

    @IBAction func disconnectPressed(_ sender: Any) {
        print("HERE")
        if (SpotifyManager.shared.appRemote.isConnected) {
            print("Disconnected")
            SpotifyManager.shared.appRemote.disconnect()
        } else {
            print("Why")
        }
    }
    // MARK: - Actions

    @objc func didTapPauseOrPlay(_ button: UIButton) {
        if let lastPlayerState = SpotifyManager.shared.lastPlayerState, lastPlayerState.isPaused {
            SpotifyManager.shared.appRemote.playerAPI?.resume(nil)
        } else {
            SpotifyManager.shared.appRemote.playerAPI?.pause(nil)
        }
    }

    @objc func didTapConnect(_ button: UIButton) {
        if #available(iOS 11, *) {
            // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
            SpotifyManager.shared.appRemote.authorizeAndPlayURI("")
        }
    }
}


// MARK: Spotify

extension SpotifyController: SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate  {
    
     func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        updateViewBasedOnConnected()
        SpotifyManager.shared.appRemote.playerAPI?.delegate = self
        SpotifyManager.shared.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
          if let error = error {
            debugPrint(error.localizedDescription)
          }
        })
        fetchPlayerState()
      }
      func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        updateViewBasedOnConnected()
        SpotifyManager.shared.lastPlayerState = nil
        
      }
      func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        updateViewBasedOnConnected()
        SpotifyManager.shared.lastPlayerState = nil
      }
      func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        update(playerState: playerState)
      }
    
    fileprivate func presentAlertController(title: String, message: String, buttonTitle: String) {
          let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
          let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
          controller.addAction(action)
          present(controller, animated: true)
      }
}
