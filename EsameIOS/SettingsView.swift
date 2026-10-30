//
//  Settings.swift
//  EsameIOS
//
//  Created by s6 on 30/10/26.
//

import SwiftUI

struct Settings: View {
    @ObservedObject private var impostazioni = UserSettings.shared
    @State var mostraPopupCancella = false

    var body: some View {
        NavigationStack{
            Form {
                Section("Utente"){
                    if(impostazioni.user_id == ""){
                        NavigationLink(destination: LoginView()) {
                            Text("Accedi o Registrati").foregroundColor(.cyan)
                        }
                    } else {
                        NavigationLink(destination: LoginView()){
                            HStack {
                                Text("Modifica dati").foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                            }
                        }
                        
                        Button(action: {
                            mostraPopupCancella = true
                        }) {
                            HStack {
                                Text("Elimina profilo").foregroundColor(.red)
                                Spacer()
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .font(.footnote)
                                
                            }
                            
                        }.alert("Sei sicuro di eliminare il profilo?", isPresented: $mostraPopupCancella){
                            Button("Annulla", role: .cancel){}
                            Button("Elimina", role: .destructive){
                                
                            }
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
