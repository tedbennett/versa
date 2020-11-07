//
//  SpotifyView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 31/10/2020.
//

import SwiftUI

struct SpotifyView: View {
    
    @ObservedObject var auth = SpotifyAuthViewModel.shared
    
    init() {
        auth.initialize()
    }
    
    var body: some View {
        if auth.authenticated {
            SpotifyPlaylistList()
        } else {
            Button(action: {
                auth.authorize()
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).frame(width: 250, height: 100)
                    Text("Log In to Spotify").foregroundColor(.white).font(.title2).padding()
                }
            })
        }
    }
}

