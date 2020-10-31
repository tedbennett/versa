//
//  AppleMusicViewModel.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import Foundation
import StoreKit
import AppleMusicAPI

class AppleMusicAuthViewModel: ObservableObject {
    
    static let shared = AppleMusicAuthViewModel()
    
    private init() {}
    
    @Published var authenticated = false
    
    private var SKController = SKCloudServiceController()
    
    private var developerToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IjZQRFZEWDQ3M0sifQ.eyJpc3MiOiI5WTJBTUg1UzIzIiwiZXhwIjoxNjA4ODU3NTY2LCJpYXQiOjE1OTMwNzY5NjZ9.dyrmzVt1kIMk6UWYBPmpA3fMCqVW4TBLdty5kZTQOfnQ6Z-CtrTVx4F9kaTD03DWd6VQe_EFGmE1s41fdPQ4bg"
    
    func authorize() {
        SKCloudServiceController.requestAuthorization { status in
            if status == .authorized {
                self.SKController.requestCapabilities { capabilities, error in
                    if capabilities.contains(.addToCloudMusicLibrary) {
                        self.SKController.requestUserToken(forDeveloperToken: self.developerToken) { userToken, error in
                            if let userToken = userToken {
                                self.authenticated = true
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
}

