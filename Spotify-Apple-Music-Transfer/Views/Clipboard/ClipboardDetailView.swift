//
//  ClipboardDetailView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 18/03/2021.
//

import SwiftUI
import AlertToast

struct ClipboardDetailView: View {
    var name: String
    var artist: String?
    var album: String?
    var url: URL?
    var imageUrl: String?
    

    @ObservedObject var viewModel: ClipboardViewModel
    
    @State var showSpotifyWarning = false
    @State var showAppleMusicWarning = false
    
    var state: ClipboardState
    
    var openInServiceString: String {
        switch state {
            case .spotifySong, .spotifyAlbum, .spotifyArtist:
                return "Open In Spotify"
            case .appleMusicSong, .appleMusicAlbum, .appleMusicArtist:
                return "Open In Apple Music"
            case .appleMusicPlaylist:
                return "Transfer to Apple Music"
            case .spotifyPlaylist:
                return "Transfer to Spotify"
            default:
                return "Cannot find link"
        }
    }
    
    var text: String? {
        if let artist = artist {
            if let album = album {
                return "\(artist) • \(album)"
            }
            return artist
        }
        return album
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 20) {
                    Spacer()
                    ImageView(urlString: imageUrl).frame(width: 300, height: 300).cornerRadius(20)
                    Text(name).font(.largeTitle).bold().multilineTextAlignment(.center)
                    
                    if text != nil {
                        Text(text!).foregroundColor(.gray).multilineTextAlignment(.center)
                    }
                    Divider()
                    HStack {
                        Spacer()
                        Button(action: {
                            switch viewModel.state {
                                case .appleMusicPlaylist: viewModel.transferToAppleMusic()
                                case .spotifyPlaylist: viewModel.transferToSpotify()
                                default:
                                    if url != nil {
                                        UIApplication.shared.open(url!)
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                            }
                        }, label: {
                            ZStack {
                                Text(openInServiceString).font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(20)
                                    .background(Color.primary)
                                    .cornerRadius(10)
                                    .foregroundColor(Color(UIColor.systemBackground))
                            }
                        })
                        Spacer()
                    }
                    HStack(spacing: 20) {
                        if url != nil {
                            Button(action: {
                                viewModel.presentShareSheet = true
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }, label: {
                                ZStack {
                                    Circle().fill(Color.primary).frame(width: 60, height: 60)
                                    Image(systemName: "square.and.arrow.up").font(.title).foregroundColor( Color(UIColor.systemBackground)).padding()
                                }
                            })
                        }
                        switch state {
                            case  .appleMusicSong, .appleMusicAlbum:
                                Button(action: {
                                    if AuthManager.shared.authorisedApple {
                                        viewModel.addToLibrary()
                                    } else {
                                        showSpotifyWarning = false
                                        showAppleMusicWarning = true
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                }, label: {
                                    ZStack {
                                        Circle().fill(Color.primary).frame(width: 60, height: 60)
                                        Image(systemName: "plus").font(.title).foregroundColor( Color(UIColor.systemBackground)).padding()
                                    }
                                })
                            case .spotifySong, .spotifyAlbum:
                                Button(action: {
                                    if AuthManager.shared.authorisedSpotify {
                                        viewModel.addToLibrary()
                                    } else {
                                        showAppleMusicWarning = false
                                        showSpotifyWarning = true
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                }, label: {
                                    ZStack {
                                        Circle().fill(Color.primary).frame(width: 60, height: 60)
                                        Image(systemName: "plus").font(.title).foregroundColor( Color(UIColor.systemBackground)).padding()
                                    }
                                })
                            default: EmptyView()
                        }
                    }
                    if showSpotifyWarning {
                        Text("Log in to Spotify in Settings to add songs to your library")
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.red)
                    } else if showAppleMusicWarning {
                        Text("Log in to Apple Music in Settings to add songs to your library")
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.red)
                    }
                    Spacer()
                }.frame(width: geometry.size.width * 0.9)
                Spacer()
            }.animation(.easeInOut)
            .transition(.opacity)
            .blur(radius: viewModel.transferring ? 3.0 : 0.0)
            .toast(isPresenting: $viewModel.transferring) {
                AlertToast(type: .loading, title: "Transferring...", subTitle: nil)
            }
            .toast(isPresenting: $viewModel.transferSuccess, duration: 2.0, tapToDismiss: false, alert: {
                AlertToast(type: .complete(.primary), title: "Transfer complete!", subTitle: nil)
            }, completion: {_ in})
            .toast(isPresenting: $viewModel.addToLibrarySuccess, duration: 2.0, tapToDismiss: false, alert: {
                AlertToast(type: .complete(.primary), title: "Added to your Library!", subTitle: nil)
            }, completion: {_ in})
            .toast(isPresenting: $viewModel.transferFail, duration: 2.0, tapToDismiss: false, alert: {
                AlertToast(type: .error(.primary), title: "Transfer failed", subTitle: "An error occured")
            }, completion: {_ in})
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardDetailView(name: "Song", artist: "Artist", album: "Album", url: URL(string: "www.google.com")!, viewModel: ClipboardViewModel.shared, state: .appleMusicSong)
    }
}
