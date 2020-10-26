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
    
    @ObservedObject var SpotifyAuth = SpotifyAuthViewModel.shared
    @ObservedObject var AppleMusicAuth = AppleMusicAuthViewModel.shared
    
    var body: some View {
        VStack {
            if !SpotifyAuth.authenticated {
                Spacer()
                Button(action: {
                    SpotifyAuth.authorize()
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).foregroundColor(.gray).frame(width: 250, height: 100)
                        Text("Log In to Spotify").foregroundColor(.white).font(.title2).padding()
                    }
                })
            }
            if !AppleMusicAuth.authenticated {
                Spacer()
                Button(action: {
                    AppleMusicAuth.authorize()
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
