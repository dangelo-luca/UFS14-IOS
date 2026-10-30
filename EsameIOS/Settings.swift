//
//  Settings.swift
//  EsameIOS
//
//  Created by s6 on 30/10/26.
//

import SwiftUI

struct Settings: View {
    @ObservedObject private var impostazioni = UserSettings.shared

    var body: some View {
        NavigationStack{
            Form {
                Section("User"){
                    if(impostazioni.user_id == ""){
                        NavigationLink(destination: LoginView()) {
                            Text("Accedi o Registrati").foregroundColor(.cyan)
                        }
                    }
                }
                Section("App") {
                    Picker("Tema dell'app",
                           selection: $impostazioni.opzioni.theme) {
                        ForEach(impostazioni.opzioni.themesAvaiable, id: \.self) { theme in
                            Text(theme.capitalized).tag(theme)
                        }
                    }
                }
            }
        }.navigationTitle("Impostazioni")
            .preferredColorScheme(impostazioni.opzioni.getTheme())
    }
}

#Preview {
    Settings()
}
