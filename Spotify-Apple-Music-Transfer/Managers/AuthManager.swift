//
//  AuthManager.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 20/03/2021.
//

import Combine
import SpotifyAPI
import AppleMusicAPI
import StoreKit

class AuthManager: ObservableObject {
    
    static var shared = AuthManager()
    
    private var SKController = SKCloudServiceController()
    
    @Published var authorisedApple = false
    @Published var authorisedSpotify = false
    
    
    private var accessedApple = false {
        didSet {
            completedAuthSetup = accessedApple && accessedSpotify
        }
    }
    private var accessedSpotify = false {
        didSet {
            completedAuthSetup = accessedApple && accessedSpotify
        }
    }
    
    @Published var completedAuthSetup = false
    
    private init() {
        if UserDefaults.standard.bool(forKey: "LoggedInAppleMusic") {
            authoriseAppleMusic()
            authoriseAppleMusicWithUser()
        } else {
            authoriseAppleMusic()
        }
        authoriseSpotifyWithClientCredentials()
        if UserDefaults.standard.bool(forKey: "LoggedInSpotify") {
            authoriseSpotifyWithUser()
        }
    }
    
    func authoriseAppleMusic() {
        AppleMusicAPI.manager.initialize(developerToken: AppleMusicKeys.developerToken)
        accessedApple = true
    }
    
    func authoriseAppleMusicWithUser() {
        SKCloudServiceController.requestAuthorization { status in
            if status == .authorized {
                self.SKController.requestCapabilities { capabilities, error in
                    if capabilities.contains(.addToCloudMusicLibrary) {
                        self.SKController.requestUserToken(forDeveloperToken: AppleMusicKeys.developerToken) { userToken, error in
                            if let userToken = userToken {
                                UserDefaults.standard.set(true, forKey: "LoggedInAppleMusic")
                                AppleMusicAPI.manager.initialize(developerToken: AppleMusicKeys.developerToken, userToken: userToken)
                                self.authorisedApple = true
                            } else {
                                print(error.debugDescription)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func authoriseSpotifyWithClientCredentials() {
        SpotifyAPI.manager.authoriseWithClientCredentials(clientId: SpotifyKeys.clientId, secretId: SpotifyKeys.clientSecret, useKeychain: true) { success in
            if !success {
                print("ERROR: Failed to sign in to spotify")
            }
            DispatchQueue.main.async {
                self.accessedSpotify = success
            }
        }
    }
    
    func authoriseSpotifyWithUser() {
        SpotifyAPI.manager.authoriseWithUser(clientId: SpotifyKeys.clientId, redirectUris: ["apple-music-spotify-transfer://oauth-callback/"] , scopes: [.playlistModifyPrivate, .playlistModifyPublic, .userLibraryRead, .userLibraryModify]) { success in
            UserDefaults.standard.set(success, forKey: "LoggedInSpotify")
            DispatchQueue.main.async {
                self.authorisedSpotify = success
                self.accessedSpotify = true
            }
        }
    }
    
    func signOutAppleMusic() {
        UserDefaults.standard.set(false, forKey: "LoggedInAppleMusic")
        authorisedApple = false
        
        // TODO: Forget user
    }
    
    func signOutSpotify() {
        UserDefaults.standard.set(false, forKey: "LoggedInSpotify")
        authorisedSpotify = false
        SpotifyAPI.manager.forgetTokens()
        authoriseSpotifyWithClientCredentials()
    }
}
