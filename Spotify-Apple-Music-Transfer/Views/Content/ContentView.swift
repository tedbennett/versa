//
//  ContentView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 20/03/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var auth = AuthManager.shared
    @State var hasOpenedBefore = UserDefaults.standard.integer(forKey: "CurrentAppVersion") != AppData.version
    
    var body: some View {
        Group {
            if auth.completedAuthSetup {
                HomeView(presentInfo: $hasOpenedBefore)
            } else {
                ProgressView()
            }
        }.sheet(isPresented: $hasOpenedBefore) {
            WelcomeView(display: $hasOpenedBefore).accentColor(Color(#colorLiteral(red: 0.005734271968, green: 0.661365995, blue: 0.8820253791, alpha: 1)))
        }
        .accentColor(Color(#colorLiteral(red: 0.005734271968, green: 0.661365995, blue: 0.8820253791, alpha: 1)))
    }
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
