import SwiftUI

// Vista principale che gestisce lo scambio tra Login e Registrazione
struct AuthView: View {
    @State private var showLogin = true

    var body: some View {
        ZStack {
            if showLogin {
                LoginView(showLogin: $showLogin)
                    .transition(.opacity)
            } else {
                RegistrationView(showLogin: $showLogin)
                    .transition(.opacity)
            }
        }
    }
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    @Binding var showLogin: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AuthHeader(
                    title: "Accedi",
                    subtitle: "Inserisci le tue credenziali per continuare."
                )
                .padding(.top, 48)

                AuthFieldGroup {
                    AuthField(
                        placeholder: "Email",
                        text: $email,
                        keyboard: .emailAddress,
                        contentType: .emailAddress,
                        capitalization: .never
                    )
                    AuthDivider()
                    AuthField(
                        placeholder: "Password",
                        text: $password,
                        isSecure: true,
                        contentType: .password
                    )
                }

                Button {
                    // Logica di login
                } label: {
                    Text("Accedi")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(email.isEmpty || password.isEmpty)

                AuthSwitchLink(question: "Non hai un account?", action: "Registrati") {
                    withAnimation { showLogin = false }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    AuthView()
}
