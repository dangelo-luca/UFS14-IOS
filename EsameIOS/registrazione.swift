import SwiftUI

struct RegistrationView: View {
    @State private var nome = ""
    @State private var cognome = ""
    @State private var email = ""
    @State private var password = ""
    
    @Binding var showLogin: Bool

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
                // Logica di registrazione
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(nome.isEmpty || cognome.isEmpty || email.isEmpty || password.isEmpty)
            
            Spacer().frame(height: 20)
            
            Button(action: {
                withAnimation {
                    showLogin = true
                }
            }) {
                HStack(spacing: 4) {
                    Text("Hai già un account?")
                        .foregroundColor(.secondary)
                    
                    Text("Accedi")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .font(.callout)
            }
        }
        .padding()
    }
}

#Preview {
    RegistrationView(showLogin: .constant(false))
}
