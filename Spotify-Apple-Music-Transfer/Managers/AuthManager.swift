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
    
    let clientId = "e164f018712e4c6ba906a595591ff010"
    
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
    @Published var userDoesNotHaveAppleMusic = false
    
    private init() {
        checkAppleMusicKey { token in
            self.authoriseAppleMusic(token: token)
            if UserDefaults.standard.bool(forKey: "LoggedInAppleMusic") {
                self.authoriseAppleMusicWithUser(token: token)
            }
        }
        if !SpotifyAPI.manager.hasUserAccess() {
            if !SpotifyAPI.manager.isAuthorised() {
                authoriseSpotifyWithClientCredentials()
            } else {
                accessedSpotify = true
            }
        } else {
            accessedSpotify = true
            authorisedSpotify = true
        }
    }
    
    func startAppleMusicAuth() {
        checkAppleMusicKey { token in
            self.authoriseAppleMusicWithUser(token: token)
        }
    }
    
    func authoriseAppleMusic(token: String) {
        AppleMusicAPI.manager.initialize(developerToken: token)
        DispatchQueue.main.async {
            self.accessedApple = true
        }
    }
    
    func authoriseAppleMusicWithUser(token developerToken: String) {
        SKCloudServiceController.requestAuthorization { status in
            if status == .authorized {
                self.SKController.requestCapabilities { capabilities, error in
                    if capabilities.contains(.addToCloudMusicLibrary) {
                        self.SKController.requestUserToken(forDeveloperToken: developerToken) { userToken, error in
                            if let userToken = userToken {
                                UserDefaults.standard.set(true, forKey: "LoggedInAppleMusic")
                                AppleMusicAPI.manager.initialize(developerToken: developerToken, userToken: userToken)
                                DispatchQueue.main.async {
                                    self.authorisedApple = true
                                }
                            } else {
                                print(error.debugDescription)
                            }
                        }
                    } else {
                        self.userDoesNotHaveAppleMusic = true
                    }
                }
            }
        }
    }
    
    func authoriseSpotifyWithClientCredentials() {
        getClientCredentials { access, expiry in
            let success = access != nil && expiry != nil
            if let access = access, let expiry = expiry {
                SpotifyAPI.manager.authorise(accessToken: access, refresh: nil, expiry: expiry, clientId: self.clientId)
            }
            DispatchQueue.main.async {
                self.accessedSpotify = success
            }
        }
    }
    
    func authoriseSpotifyWithUser(code: String) {
        getCodeCredentials(code: code) { access, refresh, expiry in
            let success = access != nil && refresh != nil && expiry != nil
            if let access = access, let refresh = refresh, let expiry = expiry {
                SpotifyAPI.manager.authorise(accessToken: access, refresh: refresh, expiry: expiry, clientId: self.clientId)
                UserDefaults.standard.set(success, forKey: "LoggedInSpotify")
            }
            DispatchQueue.main.async {
                self.authorisedSpotify = success
                if success {
                    self.accessedSpotify = true
                }
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
    
    func checkAppleMusicKey(completion: @escaping (String) -> ()) {
        
        if let expiry = UserDefaults.standard.object(forKey: "AppleMusicKeyExpiry") as? Date,
            expiry > Date(),
            let key = UserDefaults.standard.string(forKey: "AppleMusicKey") {
            completion(key)
        } else {
            getAppleMusicToken {
                completion($0)
            }
        }
    }
    
    func getClientCredentials(completion: @escaping (String?, Date?) -> ()) {
        let url = URL(string: "https://11tg9r8wn3.execute-api.eu-west-1.amazonaws.com/v1/clientCredentials")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                      return
                  }
            
            let token = json["access_token"] as? String
            let expiresIn = json["expires_in"] as? Double
            let expiration = expiresIn != nil ? Date(timeIntervalSince1970: expiresIn!) : nil
            completion(token, expiration)
        }.resume()
    }
    
    func getCodeCredentials(code: String, completion: @escaping (String?, String?, Date?) -> ()) {
        let url = URL(string: "https://11tg9r8wn3.execute-api.eu-west-1.amazonaws.com/v1/codeCredentials")!
        
        let body = try! JSONSerialization.data(withJSONObject: ["code": code], options: [])
        
        var request = URLRequest(url: url)
        request.httpBody = body
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                      return
                  }
            
            let token = json["access_token"] as? String
            let refresh = json["refresh_token"] as? String
            let expiresIn = json["expires_in"] as? Double
            let expiration = expiresIn != nil ? Date(timeIntervalSince1970: expiresIn!) : nil
            completion(token, refresh, expiration)
        }.resume()
    }
    
    func getAppleMusicToken(completion: @escaping (String) -> ()) {
        let url = URL(string: "https://11tg9r8wn3.execute-api.eu-west-1.amazonaws.com/v1/versa-apple-music-token")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                      return
                  }
            
            let token = json["token"] as? String ?? ""
            let expiry = json["expiresIn"] as? Double
            
            UserDefaults.standard.set(token, forKey: "AppleMusicKey")
            if let expiry = expiry {
                let date = Date().addingTimeInterval(expiry)
                UserDefaults.standard.set(date, forKey: "AppleMusicKeyExpiry")
            }
            completion(token)
        }.resume()
    }
}
