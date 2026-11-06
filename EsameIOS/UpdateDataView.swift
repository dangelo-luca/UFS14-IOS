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
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var impostazioni = UserSettings.shared
    
    @State private var user: User? = nil
    
    @State private var nome = ""
    @State private var cognome = ""
    
    @State private var oldPsw = ""
    @State private var newPsw1 = ""
    @State private var newPsw2 = ""
    
    @State private var erroreVecchiaPsw = false
    @State private var errorePswNonCoincidenti = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Modifica Dati").font(.title).bold()
                
                TextField("Nome", text: $nome)
                    .textFieldStyle(.roundedBorder)
                TextField("Cognome", text: $cognome)
                    .textFieldStyle(.roundedBorder)
                
                Button("Conferma nuovo nome", action: {
                    if let utenteAttuale = user {
                        utenteAttuale.name = nome
                        utenteAttuale.surname = cognome
                        try? modelContext.save()
                    }
                })
                .buttonStyle(.borderedProminent)
                .disabled(nome.isEmpty || cognome.isEmpty)
                
                Divider().padding(.vertical)
                
                SecureField("Vecchia Password", text: $oldPsw)
                    .textFieldStyle(.roundedBorder)
                SecureField("Nuova Password", text: $newPsw1)
                    .textFieldStyle(.roundedBorder)
                SecureField("Conferma Password", text: $newPsw2)
                    .textFieldStyle(.roundedBorder)
                
                Button("Conferma nuova password", action: {
                    guard let utenteAttuale = user else { return }
                    
                    let oldHash = hashPassword(psw: oldPsw)
                    
                    if oldHash != utenteAttuale.passwordHash {
                        erroreVecchiaPsw = true
                        oldPsw = ""
                        newPsw1 = ""
                        newPsw2 = ""
                        return
                    }
                    
                    if newPsw1 != newPsw2 {
                        errorePswNonCoincidenti = true
                        oldPsw = ""
                        newPsw1 = ""
                        newPsw2 = ""
                        return
                    }
                    
                    let nuovoHash = hashPassword(psw: newPsw1)
                    utenteAttuale.passwordHash = nuovoHash
                    impostazioni.psw_hash = nuovoHash
                    
                    try? modelContext.save()
                    
                    oldPsw = ""
                    newPsw1 = ""
                    newPsw2 = ""
                    
                })
                .buttonStyle(.borderedProminent)
                .disabled(oldPsw.isEmpty || newPsw1.isEmpty || newPsw2.isEmpty)
            }
        }
        .padding()
        .onAppear {
            onInit()
        }
        .alert("Errore", isPresented: $erroreVecchiaPsw) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("La password è sbagliata")
        }
        .alert("Errore", isPresented: $errorePswNonCoincidenti) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Le due password non coincidono")
        }
    }
    
    private func onInit() {
        let currentUserId = impostazioni.user_id
        let currentPswHash = impostazioni.psw_hash
        
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { utente in
                utente.email == currentUserId
                && utente.passwordHash == currentPswHash
            }
        )
        
        if let utenteTrovato = try? modelContext.fetch(descriptor).first {
            self.user = utenteTrovato
            self.nome = utenteTrovato.name
            self.cognome = utenteTrovato.surname
        }
    }
}
