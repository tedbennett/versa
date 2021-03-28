//
//  SettingsView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 19/03/2021.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var auth = AuthManager.shared
    @Binding var presentInfo: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Apple Music"), footer: Text(!auth.authorisedApple ? "You need to log in to access your Apple Music library and add music to it" : "")) {
                    if !auth.authorisedApple {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            auth.authoriseAppleMusicWithUser()
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
                            auth.authoriseSpotifyWithUser()
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
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(presentInfo: .constant(false))
    }
}
