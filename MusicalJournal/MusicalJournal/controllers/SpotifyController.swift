//
//  ViewController.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-15.
//  Copyright © 2019 musicaljournal. All rights reserved.
//
import UIKit

class SpotifyController: UIViewController {

    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Subviews
    fileprivate lazy var connectLabel: UILabel = {
        let label = UILabel()
        label.text = "Connect your Spotify account"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    fileprivate lazy var connectButton = ConnectButton(title: "CONNECT")
    fileprivate lazy var disconnectButton = ConnectButton(title: "DISCONNECT")

    fileprivate lazy var pauseAndPlayButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(didTapPauseOrPlay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor.white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    fileprivate lazy var trackLabel: UILabel = {
        let trackLabel = UILabel()
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        trackLabel.textColor = UIColor.white
        trackLabel.textAlignment = .center
        return trackLabel
    }()
    
    fileprivate lazy var playGeneratedSong: UIButton = {
        let button = UIButton()
        
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        SpotifyManager.shared.appRemote.delegate = self
//        /view.backgroundColor = UIColor.white
        view.addSubview(connectLabel)
        view.addSubview(connectButton)
        view.addSubview(disconnectButton)
        view.addSubview(imageView)
        view.addSubview(trackLabel)
        view.addSubview(pauseAndPlayButton)

        let constant: CGFloat = 16.0

        connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        disconnectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        disconnectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true

        connectLabel.centerXAnchor.constraint(equalTo: connectButton.centerXAnchor).isActive = true
        connectLabel.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -constant).isActive = true

        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        imageView.bottomAnchor.constraint(equalTo: trackLabel.topAnchor, constant: -constant).isActive = true

        trackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        trackLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: constant).isActive = true
        trackLabel.bottomAnchor.constraint(equalTo: connectLabel.topAnchor, constant: -constant).isActive = true

        pauseAndPlayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pauseAndPlayButton.topAnchor.constraint(equalTo: trackLabel.bottomAnchor, constant: constant).isActive = true
        pauseAndPlayButton.widthAnchor.constraint(equalToConstant: 50)
        pauseAndPlayButton.heightAnchor.constraint(equalToConstant: 50)
        pauseAndPlayButton.sizeToFit()
        
//        playGeneratedSong.
        
        connectButton.sizeToFit()
        disconnectButton.sizeToFit()
        
        connectButton.addTarget(self, action: #selector(didTapConnect(_:)), for: .touchUpInside)
        disconnectButton.addTarget(self, action: #selector(didTapDisconnect(_:)), for: .touchUpInside)

        updateViewBasedOnConnected()
    }

    func update(playerState: SPTAppRemotePlayerState) {
        if SpotifyManager.shared.lastPlayerState?.track.uri != playerState.track.uri {
            fetchArtwork(for: playerState.track)
        }
        SpotifyManager.shared.lastPlayerState = playerState
        trackLabel.text = playerState.track.name
        if playerState.isPaused {
            let image = UIImage(named: "play")
            pauseAndPlayButton.setImage(image, for: .normal)
            pauseAndPlayButton.tintColor = UIColor.white
        } else {
            let image = UIImage(named: "pause")
            pauseAndPlayButton.setImage(image, for: .normal)
            pauseAndPlayButton.tintColor = UIColor.white
        }
    }

    func updateViewBasedOnConnected() {
        if (SpotifyManager.shared.appRemote.isConnected) {
            connectButton.isHidden = true
            disconnectButton.isHidden = false
            connectLabel.isHidden = true
            imageView.isHidden = false
            trackLabel.isHidden = false
            pauseAndPlayButton.isHidden = false
        } else {
            disconnectButton.isHidden = true
            connectButton.isHidden = false
            connectLabel.isHidden = false
            imageView.isHidden = true
            trackLabel.isHidden = true
            pauseAndPlayButton.isHidden = true
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

    // MARK: - Actions
    @objc func didTapPauseOrPlay(_ button: UIButton) {
        if let lastPlayerState = SpotifyManager.shared.lastPlayerState, lastPlayerState.isPaused {
            SpotifyManager.shared.appRemote.playerAPI?.resume(nil)
        } else {
            SpotifyManager.shared.appRemote.playerAPI?.pause(nil)
        }
    }

    @objc func didTapDisconnect(_ button: UIButton) {
        if (SpotifyManager.shared.appRemote.isConnected) {
            SpotifyManager.shared.appRemote.disconnect()
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
        SpotifyManager.shared.appRemote.playerAPI?.play("", callback: .some({ (success, error) in
            if let error = error {
                print(error)
            } else {
                self.fetchPlayerState()
            }
        }))
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
