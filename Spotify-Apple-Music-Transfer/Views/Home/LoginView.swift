//
//  LoginView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 17/03/2021.
//

import SwiftUI

struct LoginView: View {
    var isLoggedIn: Bool {
        spotifyAuth.authenticated && appleAuth.authenticated
    }
    @StateObject var spotifyAuth = SpotifyAuthViewModel.shared
    @StateObject var appleAuth = AppleMusicAuthViewModel.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    Image("apple_music_icon").resizable().frame(width: 50, height: 50)
                Button(action: {
                    appleAuth.authorize()
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).frame(width: 250, height: 100)
                        Text("Log In to Apple Music").foregroundColor(.white).font(.title2).padding()
                    }
                })
                }
                Spacer()
                HStack {
                    Image("spotify_icon").resizable().frame(width: 50, height: 50)
                    Button(action: {
                        spotifyAuth.authorize()
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).frame(width: 250, height: 100)
                            Text("Log In to Spotify").foregroundColor(.white).font(.title2).padding()
                        }
                    })
                }
                Spacer()
                NavigationLink(
                    destination: HomeView(),
                    label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20).foregroundColor(isLoggedIn ? .blue : .gray).frame(width: 250, height: 50)
                            HStack {
                            Text("Continue").foregroundColor(.white).font(.title2).padding()
                                Image(systemName: "chevron.right").foregroundColor(.white)
                            }
                        }
                    })
            }.navigationTitle("APP")
        }
    }
}

struct HomeVIew_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
    }
}
