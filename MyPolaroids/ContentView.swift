//
//  ContentView.swift
//  MyPolaroids
//
//  Created by Edoardo Galati on 8/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                NotificationManager.shared.handleAppDidBecomeActive()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                NotificationManager.shared.handleAppDidEnterBackground()
            }
    }
}

#Preview {
    ContentView()
}
