//
//  AppleMusicView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 31/10/2020.
//

import SwiftUI

struct AppleMusicView: View {
    
    @ObservedObject var auth = AppleMusicAuthViewModel.shared
    
    var body: some View {
        if auth.authenticated {
            AppleMusicPlaylistList()
        } else {
            Button(action: {
                auth.authorize()
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).frame(width: 250, height: 100)
                    Text("Log In to Apple Music").foregroundColor(.white).font(.title2).padding()
                }
            })
        }
    }
}

