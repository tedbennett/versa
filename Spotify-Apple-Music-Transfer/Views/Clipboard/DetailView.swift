//
//  DetailView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 18/03/2021.
//

import SwiftUI

struct DetailView: View {
    var name: String
    var artist: String?
    var album: String?
    var url: URL?
    var imageUrl: String?
    
    @Binding var presentShareSheet: Bool
    
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
                    Divider()
                    if text != nil {
                        Text(text!).foregroundColor(.gray).multilineTextAlignment(.center)
                    }
                    Spacer(minLength: 0)
                    HStack {
                        Spacer()
                        Button(action: {
                            if url != nil {
                                UIApplication.shared.open(url!)
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
                    HStack {
                        if url != nil {
                            Button(action: {
                                presentShareSheet = true
                            }, label: {
                                ZStack {
                                    Circle().fill(Color.primary).frame(width: 60, height: 60)
                                    Image(systemName: "square.and.arrow.up").font(.title).foregroundColor( Color(UIColor.systemBackground)).padding()
                                }
                            })
                        }
                    }
                    Spacer()
                }.frame(width: geometry.size.width * 0.8)
                Spacer()
            }.animation(.easeInOut)
            .transition(.opacity)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(name: "Song", artist: "Artist", album: "Album", url: URL(string: "www.google.com")!, presentShareSheet: .constant(false), state: .appleMusicSong)
    }
}
