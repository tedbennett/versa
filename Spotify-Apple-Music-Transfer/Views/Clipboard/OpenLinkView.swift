//
//  OpenLinkView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 28/10/2020.
//

import SwiftUI

struct OpenLinkView: View {
    
    @ObservedObject var viewModel = OpenLinkViewModel.shared
    @State var presentShareSheet = false
    
    
    var searching: some View {
        VStack(spacing: 30) {
            ProgressView()
            Text("Searching...")
        }.foregroundColor(.gray)
    }
    
    var noUrl: some View {
        VStack(spacing: 30) {
            Image(systemName: "exclamationmark.triangle").font(.largeTitle)
            Text("Couldn't find a URL in the clipboard").multilineTextAlignment(.center)
            Text("Copy the url for a song, album or artist on Apple Music or Spotify, and open this app to convert link for the other music service").multilineTextAlignment(.center)
        }.foregroundColor(.gray)
    }
    
    var invalidUrl: some View {
        VStack(spacing: 30) {
            Image(systemName: "exclamationmark.triangle").font(.largeTitle)
            Text("Oops! The URL in the clipboard is not a valid Spotify or Apple Music link").multilineTextAlignment(.center)
        }.foregroundColor(.gray)
    }
    
    var failedToFindOnSpotify: some View {
        VStack(spacing: 30) {
            Image(systemName: "exclamationmark.triangle").font(.largeTitle)
            Text("Oops! The requested resource could not be found on Spotify").multilineTextAlignment(.center)
        }.foregroundColor(.gray)
    }
    
    var failedToFindOnAppleMusic: some View {
        VStack(spacing: 30) {
            Image(systemName: "exclamationmark.triangle").font(.largeTitle)
            Text("Oops! The requested resource could not be found on Apple Music").multilineTextAlignment(.center)
        }.foregroundColor(.gray)
    }
    
    
    var body: some View {
        VStack {
            switch viewModel.state {
                case .searching: searching
                case .noUrl: noUrl
                case .invalidUrl: invalidUrl
                case .failedToFindOnAppleMusic: failedToFindOnAppleMusic
                case .failedToFindOnSpotify: failedToFindOnSpotify
                case .spotifySong, .spotifyAlbum, .spotifyArtist, .spotifyPlaylist, .appleMusicSong, .appleMusicAlbum, .appleMusicArtist, .appleMusicPlaylist: DetailView(name: viewModel.name ?? "Unknown", artist: viewModel.artistName, album: viewModel.albumName, url: viewModel.url, imageUrl: viewModel.imageUrl, presentShareSheet: $presentShareSheet, state: viewModel.state)
                default: Text("Hi")
            }
        }
        .onAppear {
            viewModel.parseClipboard(UIPasteboard.general.string)
        }
        .sheet(isPresented: $presentShareSheet) {
            ShareSheet(itemsToShare: [viewModel.url!])
        }
    }
}
