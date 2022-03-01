//
//  SettingsView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 19/03/2021.
//

import SwiftUI
import BetterSafariView

struct SettingsView: View {
    @ObservedObject var auth = AuthManager.shared
    @State var presentSpotifyLogin = false
    @Binding var presentInfo: Bool
    
    private let AUTHORISE_SPOTIFY_URL = URL(string: "https://accounts.spotify.com/authorize?client_id=e164f018712e4c6ba906a595591ff010&response_type=code&redirect_uri=versa://oauth-callback/&scope=playlist-modify-private%20playlist-modify-public%20user-library-read%20user-library-modify&show_dialog=true")!
    
    var webAuthSession: WebAuthenticationSession {
        WebAuthenticationSession(
            url: AUTHORISE_SPOTIFY_URL,
            callbackURLScheme: "kude"
        ) { callbackURL, error in
            guard let callbackURL = callbackURL, error == nil,
                  let url = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true),
                  let code = url.queryItems?.first(where: { $0.name == "code" })?.value else {
                      print(error.debugDescription)
                      return
                  }
            auth.authoriseSpotifyWithUser(code: code)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Apple Music"), footer: Text(!auth.authorisedApple ? "You need to log in to access your Apple Music library and add music to it" : "")) {
                    if !auth.authorisedApple {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            auth.startAppleMusicAuth()
                        } label: {
                            HStack {
                                Image("apple_music_icon").resizable().frame(width: 50, height: 50)
                                Text("Log In to Apple Music").padding()
                                
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                        }.buttonStyle(PlainButtonStyle())
                    } else {
                        HStack {
                            Image("apple_music_icon").resizable().frame(width: 50, height: 50)
                            Text("Logged in to Apple Music").padding()
                            
                            Spacer()
                            Image(systemName: "checkmark").foregroundColor(.gray)
                        }
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            auth.signOutAppleMusic()
                        } label: {
                            Text("Logout").foregroundColor(.red)
                        }
                    }
                }
                Section(header: Text("Spotify"), footer: Text(!auth.authorisedSpotify ? "You need to log in to access your Spotify library and add music to it" : "")) {
                    
                    
                    if !auth.authorisedSpotify {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            presentSpotifyLogin = true
                        } label: {
                            HStack {
                                Image("spotify_icon").resizable().frame(width: 50, height: 50)
                                Text("Log In to Spotify").padding()
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                        }.buttonStyle(PlainButtonStyle())
                    } else {
                        
                        HStack {
                            Image("spotify_icon").resizable().frame(width: 50, height: 50)
                            Text("Logged in to Spotify").padding()
                            
                            Spacer()
                            Image(systemName: "checkmark").foregroundColor(.gray)
                        }
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            auth.signOutSpotify()
                        }, label: {
                            Text("Logout").foregroundColor(.red)
                        })
                    }
                }
            }.listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            
            .navigationBarItems(trailing: Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                presentInfo = true
            } label: {
                Image(systemName: "info.circle").font(.title2)
            })
            .alert(isPresented: $auth.userDoesNotHaveAppleMusic) {
                Alert(title: Text("Apple Music Subcription Not Found"), message: Text("Could not find an Apple Music subscription associated with your Apple ID"), dismissButton: .default(Text("OK")))
            }
            .webAuthenticationSession(isPresented: $presentSpotifyLogin) {
                webAuthSession
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(presentInfo: .constant(false))
    }
}
