//
//  OpenLinkView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 28/10/2020.
//

import SwiftUI

struct OpenLinkView: View {
    
    @ObservedObject var viewModel = OpenLinkViewModel.shared
    
    var openInServiceString: String {
        switch viewModel.state {
            case .spotifySong, .spotifyAlbum, .spotifyArtist, .spotifyPlaylist:
                return "Open In Spotify"
            case .appleMusicSong, .appleMusicAlbum, .appleMusicArtist, .appleMusicPlaylist:
                return "Open In Apple Music"
            default:
                return "Cannot find link"
        }
    }
    
    var body: some View {
        VStack {
            ImageView(urlString: viewModel.imageUrl)
            Text(viewModel.name ?? "Unknown").font(.largeTitle)
            if (viewModel.albumName != nil) {
                Text(viewModel.albumName!).font(.title3)
            }
            if (viewModel.artistName != nil) {
                Text(viewModel.artistName!).font(.title3)
            }
            Button(action: {
                if viewModel.url != nil {
                    UIApplication.shared.open(viewModel.url!)
                }
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(Color.white)
                    Text(openInServiceString).font(.title3)
                }
            })
        }
    }
}
