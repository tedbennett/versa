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
    
    private var developerToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IlEzM0taS0QzS0MifQ.eyJpc3MiOiI5WTJBTUg1UzIzIiwiZXhwIjoxNjMxNTI3Nzg3LCJpYXQiOjE2MTU3NTQzODd9.NkPw4EQu0oOlTJDE52pEaWjCSGwPD_vOly-3YH8xjEwkaaecJSHt39E4qNV1l5YZnzD_d7YjN-gvNuzjoQkKIg"
    
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

