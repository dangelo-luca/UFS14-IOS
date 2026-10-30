//
//  EsameIOSApp.swift
//  EsameIOS
//
//  Created by d14 on 13/10/26.
//

import SwiftUI

@main
struct EsameIOSApp: App {
    @State private var buildManager = BuildManager()
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(buildManager)
        }
    }
}
