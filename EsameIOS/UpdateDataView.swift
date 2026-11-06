//
//  UpdateDataView.swift
//  EsameIOS
//
//  Created by s6 on 06/11/26.
//

import SwiftUI
import SwiftData
import CryptoKit

struct UpdateDataView: View {
    @Environment(\.modelContext) var modelContext
    @Query var utenti: [User]
    
    @ObservedObject var impostazioni = UserSettings.shared
    
    @Bindable var user : User
    
    @State var nome = ""
    @State var cognome = ""
    
    @State var oldPsw = ""
    @State var newPsw1 = ""
    @State var newPsw2 = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Modifica Dati").font(.title).bold()
                TextField("Nome", text: $nome)
                    .textFieldStyle(.roundedBorder)
                TextField("Cognome", text: $cognome)
                    .textFieldStyle(.roundedBorder)
                
                Button("Conferma nuovo nome", action: {
                    user.name = nome
                    user.surname = cognome
                    
                    try? modelContext.save()
                }).buttonStyle(.borderedProminent)
                    .disabled(nome.isEmpty || cognome.isEmpty)
                
                SecureField("Vecchia Password", text: $oldPsw)
                    .textFieldStyle(.roundedBorder)
                SecureField("Nuova Password", text: $newPsw1)
                    .textFieldStyle(.roundedBorder)
                SecureField("Conferma Password", text: $newPsw2)
                    .textFieldStyle(.roundedBorder)
                
                Button("Conferma nuova password", action: {
                    let oldHash = hashPassword(psw: oldPsw)
                    
                    if(oldHash != user.passwordHash || (newPsw1 != newPsw2)){
                        //TODO: Alert
                        oldPsw = ""
                        newPsw1 = ""
                        newPsw2 = ""
                        
                        return
                    }
                    
                    user.passwordHash = hashPassword(psw: newPsw1)
                    
                    try? modelContext.save()
                    
                }).buttonStyle(.borderedProminent)
                    .disabled(oldPsw.isEmpty || newPsw1.isEmpty || newPsw2.isEmpty)
            }
            
            
        }.padding()
            .onAppear {
                onInit()
            }
    }
    
    private func onInit(){
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User>{utente in
                utente.id == impostazioni.user_id
                && utente.passwordHash == impostazioni.psw_hash
            }
        )
        
        if let utenteTrovato = try? modelContext.fetch(descriptor).first {
            user.name = utenteTrovato.name
            user.surname = utenteTrovato.surname
            user.email = utenteTrovato.email
            user.passwordHash = utenteTrovato.passwordHash
            nome = user.name
            cognome = user.surname
        }
    }
}

