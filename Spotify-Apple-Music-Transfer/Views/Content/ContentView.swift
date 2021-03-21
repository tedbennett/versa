//
//  ContentView.swift
//  Spotify-Apple-Music-Transfer
//
//  Created by Ted Bennett on 20/03/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var auth = AuthManager.shared
    var hasOpenedBefore: Bool
    
    init() {
        hasOpenedBefore = UserDefaults.standard.bool(forKey: "OpenedBefore")
    }
    
    var body: some View {
        if auth.completedAuthSetup {
            if hasOpenedBefore {
                HomeView()
            } else {
                LoginView()
            }
        } else {
            ProgressView()
        }
    }
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
