import SwiftUI
import SwiftData

struct RegistrationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var impostazioni = UserSettings.shared
    
    @State private var nome = ""
    @State private var cognome = ""
    @State private var email = ""
    @State private var password = ""
    @State private var mostraErroreEmail = false
    
    @Binding var showLogin: Bool
    var onSuccess: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Crea Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            TextField("Nome", text: $nome)
                .textFieldStyle(.roundedBorder)
            
            TextField("Cognome", text: $cognome)
                .textFieldStyle(.roundedBorder)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            Button("Registrati") {
                effettuaRegistrazione()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(nome.isEmpty || cognome.isEmpty || email.isEmpty || password.isEmpty)
            
            Spacer().frame(height: 20)
            
            Button(action: {
                withAnimation {
                    showLogin = true
                }

                Button {
                    // Logica di registrazione
                } label: {
                    Text("Registrati")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(nome.isEmpty || cognome.isEmpty || email.isEmpty || password.isEmpty)

                AuthSwitchLink(question: "Hai già un account?", action: "Accedi") {
                    withAnimation { showLogin = true }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .padding()
        .alert("Errore", isPresented: $mostraErroreEmail) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Esiste già un account con questa email.")
        }
    }
    
    private func effettuaRegistrazione() {
        let cleanNome = nome.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCognome = cognome.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { utente in
                utente.email == cleanEmail
            }
        )
        
        if (try? modelContext.fetch(descriptor).first) != nil {
            mostraErroreEmail = true
            return
        }
        
        let hash = hashPassword(psw: password)
        let nuovoUtente = User(name: cleanNome, surname: cleanCognome, email: cleanEmail, passwordHash: hash)
        
        modelContext.insert(nuovoUtente)
        try? modelContext.save()
        
        impostazioni.user_id = nuovoUtente.email
        impostazioni.psw_hash = nuovoUtente.passwordHash
        
        onSuccess?()
        dismiss()
    }
}

#Preview {
    RegistrationView(showLogin: .constant(false))
        .modelContainer(for: [User.self, Build.self], inMemory: true)
}
