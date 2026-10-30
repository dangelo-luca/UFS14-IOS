//
//  Settings.swift
//  EsameIOS
//
//  Created by s6 on 30/10/26.
//

import SwiftUI

struct Settings: View {
    @ObservedObject private var impostazioni = UserSettings.shared
    
    @State private var schemaColore: ColorScheme? = nil

    var body: some View {
        NavigationStack{
            Form {
                Section("App") {
                    Picker("Tema dell'app",
                           selection: $impostazioni.opzioni.theme) {
                        ForEach(impostazioni.opzioni.themesAvaiable, id: \.self) { theme in
                            Text(theme.capitalized).tag(theme)
                        }
                    }.onChange(of: impostazioni.opzioni.theme) {
                        oldV, newV in
                        switch newV {
                            case "light": schemaColore = .light
                            case "dark":  schemaColore = .dark
                            default:      schemaColore = nil
                        }
                    }
                }
            }
        }.navigationTitle("Impostazioni")
            .preferredColorScheme(schemaColore)
    }
}

#Preview {
    Settings()
}
