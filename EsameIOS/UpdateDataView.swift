//
//  UpdateDataView.swift
//  EsameIOS
//
//  Created by s6 on 06/11/26.
//

import SwiftUI
import SwiftData

struct UpdateDataView: View {
    @Environment(\.modelContext) var modelContext
    @Query var utenti: [User]
    
    @State var user : User?
    
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
                    
                }).buttonStyle(.borderedProminent)
                    .disabled(nome.isEmpty || cognome.isEmpty)
                
                SecureField("Vecchia Password", text: $oldPsw)
                    .textFieldStyle(.roundedBorder)
                SecureField("Nuova Password", text: $newPsw1)
                    .textFieldStyle(.roundedBorder)
                SecureField("Conferma Password", text: $newPsw2)
                    .textFieldStyle(.roundedBorder)
                
                Button("Conferma nuova password", action: {
                    
                }).buttonStyle(.borderedProminent)
                    .disabled(oldPsw.isEmpty || newPsw1.isEmpty || newPsw2.isEmpty)
            }
            
            
        }.padding()
    }
    
    private func onInit(){
    
    }
}

#Preview {
    UpdateDataView()
}
