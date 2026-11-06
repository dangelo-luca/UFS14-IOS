import SwiftUI
import SwiftData

// Vista principale che gestisce lo scambio tra Login e Registrazione
struct AuthView: View {
    var onSuccess: (() -> Void)? = nil
    @State private var showLogin = true
    
    var body: some View {
        if showLogin {
            LoginView(showLogin: $showLogin, onSuccess: onSuccess)
                .transition(.opacity)
        } else {
            RegistrationView(showLogin: $showLogin, onSuccess: onSuccess)
                .transition(.opacity)
        }
    }
}

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var impostazioni = UserSettings.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var mostraErrore = false
    
    @Binding var showLogin: Bool
    var onSuccess: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            Button("Accedi") {
                effettuaLogin()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(email.isEmpty || password.isEmpty)
            
            Spacer().frame(height: 20)
            
            Button(action: {
                withAnimation {
                    showLogin = false
                }
            }) {
                HStack(spacing: 4) {
                    Text("Non hai un account?")
                        .foregroundColor(.secondary)
                    
                    Text("Registrati")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .font(.callout)
            }
        }
        .padding()
        .alert("Errore", isPresented: $mostraErrore) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Email o password non corretti.")
        }
    }
    
    private func effettuaLogin() {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let hash = hashPassword(psw: password)
        
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { utente in
                utente.email == cleanEmail && utente.passwordHash == hash
            }
        )
        
        if let utenteTrovato = try? modelContext.fetch(descriptor).first {
            impostazioni.user_id = utenteTrovato.email
            impostazioni.psw_hash = utenteTrovato.passwordHash
            onSuccess?()
            dismiss()
        } else {
            mostraErrore = true
        }
    }
}

#Preview {
    AuthView()
        .modelContainer(for: [User.self, Build.self], inMemory: true)
}
