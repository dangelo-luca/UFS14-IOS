import SwiftUI

struct RegistrationView: View {
    @State private var nome = ""
    @State private var cognome = ""
    @State private var email = ""
    @State private var password = ""

    @Binding var showLogin: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AuthHeader(
                    title: "Crea account",
                    subtitle: "Inserisci i tuoi dati per iniziare."
                )
                .padding(.top, 48)

                AuthFieldGroup {
                    AuthField(
                        placeholder: "Nome",
                        text: $nome,
                        contentType: .givenName,
                        capitalization: .words
                    )
                    AuthDivider()
                    AuthField(
                        placeholder: "Cognome",
                        text: $cognome,
                        contentType: .familyName,
                        capitalization: .words
                    )
                    AuthDivider()
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
                        contentType: .newPassword
                    )
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
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    RegistrationView(showLogin: .constant(false))
}
