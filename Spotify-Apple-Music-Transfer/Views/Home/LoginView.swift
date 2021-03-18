//
//  LoginView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 17/03/2021.
//

import SwiftUI

struct LoginView: View {
    @StateObject var spotifyAuth = SpotifyAuthViewModel.shared
    @StateObject var auth = AuthViewModel.shared
    
    @State var loggedIn = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 40) {
                Text("To transfer music between services, you need to allow APP NAME to access both your Apple Music and Spotify accounts")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 40)
                    .padding(.top, 0)
                Divider()
                
                Button(action: {
                    auth.authoriseAppleMusic()
                }, label: {
                    HStack {
                        Image("apple_music_icon").resizable().frame(width: 50, height: 50)
                        Text("Log In to Apple Music")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .frame(width: 130, height: 60, alignment: .leading)
                            .padding(.horizontal, 15)
                        Spacer()
                        Image(systemName: auth.appleMusicAuthorised ? "checkmark.circle" : "circle").font(.title3)
                    }.padding()
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2)
                    )
                }).foregroundColor(.primary)
                .padding(.horizontal, 30)
                Divider()
                
                Button(action: {
                    auth.authoriseSpotify()
                }, label: {
                    HStack {
                        Image("spotify_icon").resizable().frame(width: 50, height: 50)
                        Text("Log In to Spotify")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .frame(width: 130, height: 60, alignment: .leading)
                            .padding(.horizontal, 15)
                        Spacer()
                        Image(systemName: auth.spotifyAuthorised ? "checkmark.circle" : "circle").font(.title3)
                    }.padding()
                })
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2)
                )
                .foregroundColor(.primary)
                .padding(.horizontal, 30)
                Divider()
                NavigationLink(
                    destination: HomeView(),
                    isActive: $auth.loggedIn,
                    label: {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 20).foregroundColor(isLoggedIn ? .blue : .gray).frame(width:180, height: 50)
//                            HStack {
//                                Text("Continue").foregroundColor(.white).font(.title2).padding()
//                                Image(systemName: "chevron.right").foregroundColor(.white)
//                            }
//                        }
                    })
            }.navigationTitle("Login")
        }
    }
}

struct HomeVIew_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
        
    }
}
