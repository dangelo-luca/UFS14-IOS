import SwiftUI

// Vista principale che gestisce lo scambio tra Login e Registrazione
struct AuthView: View {
    @State private var showLogin = true
    
    var body: some View {
        if showLogin {
            LoginView(showLogin: $showLogin)
                .transition(.opacity)
        } else {
            RegistrationView(showLogin: $showLogin)
                .transition(.opacity)
        }
    }
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    @Binding var showLogin: Bool

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
                // Logica di login
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
    }
}

#Preview {
    AuthView()
}
