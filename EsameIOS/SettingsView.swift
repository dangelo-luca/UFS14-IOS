//
//  Settings.swift
//  EsameIOS
//
//  Created by s6 on 30/10/26.
//

import SwiftUI
import SwiftData

struct Settings: View {
    @Environment(\.modelContext) var modelContext
    @Query var utenti: [User]
    @ObservedObject private var impostazioni = UserSettings.shared
    @State var mostraPopupCancella = false
    @State var mostraPopupDisconnettiti = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Utente") {
                    if impostazioni.user_id == "" {
                        NavigationLink(destination: AuthView()) {
                            Text("Accedi o Registrati").foregroundColor(.blue)
                        }
                    } else {
                        NavigationLink(destination: UpdateDataView()) {
                            HStack {
                                Text("Modifica dati").foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                            }
                        }
                        
                        Button(action: {
                            mostraPopupDisconnettiti = true
                        }) {
                            HStack {
                                Text("Disconnettiti").foregroundColor(.orange)
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.orange)
                                    .font(.footnote)
                            }
                        }
                        .alert("Vuoi disconnetterti?", isPresented: $mostraPopupDisconnettiti) {
                            Button("Annulla", role: .cancel) { }
                            Button("Disconnetti", role: .destructive) {
                                impostazioni.user_id = ""
                                impostazioni.psw_hash = ""
                            }
                        } message: {
                            Text("Uscirai dal profilo e dovrai riaccedere per tutte le funzionalità")
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
                        }
                        .alert("Sei sicuro di eliminare il profilo?", isPresented: $mostraPopupCancella) {
                            Button("Annulla", role: .cancel) { }
                            Button("Elimina", role: .destructive) {
                                let currentUserId = impostazioni.user_id
                                
                                let descriptor = FetchDescriptor<User>(
                                    predicate: #Predicate<User> { utente in
                                        utente.email == currentUserId
                                    }
                                )
                                
                                if let utenteTrovato = try? modelContext.fetch(descriptor).first {
                                    modelContext.delete(utenteTrovato)
                                    try? modelContext.save()
                                    
                                    impostazioni.user_id = ""
                                    impostazioni.psw_hash = ""
                                }
                            }
                        } message: {
                            Text("Eliminerai il profilo e tutti i dati a sé connessi, perderai l'accesso e tutte le build salvate")
                        }
                    }
                }
                
                Section("App") {
                    Picker("Tema dell'app", selection: $impostazioni.opzioni.theme) {
                        ForEach(impostazioni.opzioni.themesAvaiable, id: \.self) { theme in
                            Text(theme.capitalized).tag(theme)
                        }
                    }
                }
            }
            .navigationTitle("Impostazioni")
        }
        .preferredColorScheme(impostazioni.opzioni.getTheme())
    }
}

#Preview {
    Settings()
}
