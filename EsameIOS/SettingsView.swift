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
    @State var mostraPopupDisconnettiti = false

    var body: some View {
        NavigationStack{
            Form {
                Section("Utente"){
                    if(impostazioni.user_id == ""){
                        NavigationLink(destination: LoginView()) {
                            Text("Accedi o Registrati").foregroundColor(.blue)
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
                            mostraPopupDisconnettiti = true
                        }) {
                            HStack {
                                Text("Disconnettiti").foregroundColor(.orange)
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.orange)
                                    .font(.footnote)
                                
                            }
                            
                        }.alert("Vuoi disconnetterti?", isPresented: $mostraPopupDisconnettiti){
                            Button("Annulla", role: .cancel){}
                            Button("Disconnetti", role: .destructive){
                                
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
                            
                        }.alert("Sei sicuro di eliminare il profilo?", isPresented: $mostraPopupCancella){
                            Button("Annulla", role: .cancel){}
                            Button("Elimina", role: .destructive){
                                
                            }
                        } message: {
                            Text("Eliminerai il profilo e tutti i dati a sé connessi, perderai l'accesso e tutte le build salvate")
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
