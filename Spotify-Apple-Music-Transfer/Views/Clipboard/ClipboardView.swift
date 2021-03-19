//
//  ClipboardView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 28/10/2020.
//

import SwiftUI

struct ClipboardView: View {
    
    @ObservedObject var viewModel = ClipboardViewModel.shared
    @State var isDisplayed = false
    
    var searching: some View {
        VStack(spacing: 30) {
            ProgressView()
            Text("Searching...")
        }.foregroundColor(.gray)
    }
    
    var noUrl: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle").font(.largeTitle)
            Text("Couldn't find a URL in the clipboard").multilineTextAlignment(.center)
            Text("Copy the url for a song, album or artist on Apple Music or Spotify, and open this app to convert link for the other music service").multilineTextAlignment(.center)
                .padding(20)
        }.foregroundColor(.gray)
    }
    
    var invalidUrl: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle").font(.largeTitle)
            Text("Oops! The URL in the clipboard is not a valid Spotify or Apple Music link").multilineTextAlignment(.center)
                .padding(20)
        }.foregroundColor(.gray)
    }
    
    var failedToFindOnSpotify: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle").font(.largeTitle)
            Text("Oops! The requested resource could not be found on Spotify").multilineTextAlignment(.center)
                .padding(20)
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
                case .spotifySong, .spotifyAlbum, .spotifyArtist, .spotifyPlaylist, .appleMusicSong, .appleMusicAlbum, .appleMusicArtist, .appleMusicPlaylist: ClipboardDetailView(name: viewModel.name ?? "Unknown", artist: viewModel.artistName, album: viewModel.albumName, url: viewModel.url, imageUrl: viewModel.imageUrl, viewModel: viewModel, state: viewModel.state)
                default: Text("Hi")
            }
        }
        .onAppear {
            viewModel.parseClipboard(UIPasteboard.general.string)
            isDisplayed = true
        }
        .onDisappear {
            isDisplayed = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if isDisplayed {
                viewModel.parseClipboard(UIPasteboard.general.string)
            }
        }
        .sheet(isPresented: $viewModel.presentShareSheet) {
            ShareSheet(itemsToShare: [viewModel.url!])
        }
    }
}
