//
//  EsameIOSApp.swift
//  EsameIOS
//
//  Created by d14 on 13/10/26.
//

import SwiftUI
import SwiftData

@main
struct EsameIOSApp: App {
    @State private var buildManager = BuildManager()
    @AppStorage("language") private var language = "it"

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(buildManager)
                .environment(\.locale, Locale(identifier: language))
                .id(language)
        }.modelContainer(for:[User.self, Build.self])
    }
}
