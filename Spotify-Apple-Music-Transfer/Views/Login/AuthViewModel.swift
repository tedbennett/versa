//
//  AppleMusicViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import Foundation
import StoreKit
import AppleMusicAPI
import SpotifyAPI

class AuthViewModel: ObservableObject {
    
    static let shared = AuthViewModel()
    private var SKController = SKCloudServiceController()
    private var developerToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IlEzM0taS0QzS0MifQ.eyJpc3MiOiI5WTJBTUg1UzIzIiwiZXhwIjoxNjMxNTI3Nzg3LCJpYXQiOjE2MTU3NTQzODd9.NkPw4EQu0oOlTJDE52pEaWjCSGwPD_vOly-3YH8xjEwkaaecJSHt39E4qNV1l5YZnzD_d7YjN-gvNuzjoQkKIg"
    
    @Published var appleMusicAuthorised = false {
        didSet {
            loggedIn = appleMusicAuthorised && spotifyAuthorised
        }
    }
    @Published var spotifyAuthorised = false {
        didSet {
            loggedIn = appleMusicAuthorised && spotifyAuthorised
        }
    }
    @Published var loggedIn = false
    
   
    private init() {
        if UserDefaults.standard.bool(forKey: "LoggedInAppleMusic") {
            authoriseAppleMusic()
        }
        SpotifyAPI.manager.initialize(clientId: "e164f018712e4c6ba906a595591ff010", redirectUris: ["apple-music-spotify-transfer://oauth-callback/"] , scopes: [.playlistModifyPrivate, .playlistModifyPublic, .userLibraryRead, .userLibraryModify])
        if SpotifyAPI.manager.isAuthorised() {
            authoriseSpotify()
        }
    }
    
    
    func authoriseAppleMusic() {
        SKCloudServiceController.requestAuthorization { status in
            if status == .authorized {
                self.SKController.requestCapabilities { capabilities, error in
                    if capabilities.contains(.addToCloudMusicLibrary) {
                        self.SKController.requestUserToken(forDeveloperToken: self.developerToken) { userToken, error in
                            if let userToken = userToken {
                                UserDefaults.standard.set(true, forKey: "LoggedInAppleMusic")
                                self.appleMusicAuthorised = true
                                AppleMusicAPI.manager.initialize(developerToken: self.developerToken, userToken: userToken)
                            } else {
                                print(error.debugDescription)
                            }
                        }
                    }
                }
            }
        }
    }
    func authoriseSpotify() {
        SpotifyAPI.manager.authorize { success in
            self.spotifyAuthorised = success
        }
    }
    
    func logoutSpotify() {
        SpotifyAPI.manager.forgetTokens()
        spotifyAuthorised = false
    }
    
    func logoutAppleMusic() {
        appleMusicAuthorised = false
    }
}

