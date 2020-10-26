//
//  AddServiceView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 26/10/2020.
//

import SwiftUI
import SpotifyAPI
import AppleMusicAPI
import StoreKit

struct AddServiceView: View {
    
    var spotifyManager = SpotifyAPI.manager
    @ObservedObject var AMViewModel = AppleMusicAuthViewModel.shared
    
    @State private var loggedInToSpotify = false
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                spotifyManager.authorize { success in
                    if success {
                        loggedInToSpotify = true
                    }
                }
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).frame(width: 250, height: 100)
                    Text("Log In to Spotify").foregroundColor(.white).font(.title2).padding()
                }
            })
            if !AMViewModel.authenticated {
                Spacer()
                Button(action: {
                    AMViewModel.authorize()
                }, label: {
                    ZStack {
                    RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).frame(width: 250, height: 100)
                    Text("Log In to Apple Music").foregroundColor(.white).font(.title2).padding()
                    }
                })
            }
            Spacer()
        }
    }
}

struct AddServiceView_Previews: PreviewProvider {
    static var previews: some View {
        AddServiceView()
    }
}
