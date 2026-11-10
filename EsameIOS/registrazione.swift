import SwiftUI
import SwiftData

struct RegistrationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var impostazioni = UserSettings.shared

    private enum Campo { case nome, cognome, email, password }

    @State private var nome = ""
    @State private var cognome = ""
    @State private var email = ""
    @State private var password = ""
    @State private var mostraErroreEmail = false
    @FocusState private var focus: Campo?

    @Binding var showLogin: Bool
    var onSuccess: (() -> Void)? = nil

    private var puoRegistrarsi: Bool {
        !nome.trimmingCharacters(in: .whitespaces).isEmpty &&
        !cognome.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AuthHeader(
                    title: "Crea account",
                    subtitle: "Salva le tue configurazioni e ritrovale su ogni accesso."
                )
                .padding(.top, 32)

                AuthFieldGroup {
                    AuthField(placeholder: "Nome",
                              text: $nome,
                              contentType: .givenName,
                              capitalization: .words)
                        .focused($focus, equals: .nome)
                        .onSubmit { focus = .cognome }

                    AuthDivider()

                    AuthField(placeholder: "Cognome",
                              text: $cognome,
                              contentType: .familyName,
                              capitalization: .words)
                        .focused($focus, equals: .cognome)
                        .onSubmit { focus = .email }

                    AuthDivider()

                    AuthField(placeholder: "Email",
                              text: $email,
                              keyboard: .emailAddress,
                              contentType: .emailAddress,
                              capitalization: .never)
                        .focused($focus, equals: .email)
                        .onSubmit { focus = .password }

                    AuthDivider()

                    AuthField(placeholder: "Password",
                              text: $password,
                              isSecure: true,
                              contentType: .newPassword,
                              submitLabel: .go)
                        .focused($focus, equals: .password)
                        .onSubmit { if puoRegistrarsi { effettuaRegistrazione() } }
                }

                if mostraErroreEmail {
                    AuthErrorLabel(message: "Esiste già un account con questa email.")
                }

                AuthPrimaryButton(title: "Registrati", isEnabled: puoRegistrarsi) {
                    effettuaRegistrazione()
                }

                AuthSwitchLink(
                    question: "Hai già un account?",
                    action: "Accedi",
                    onTap: {
                        withAnimation { showLogin = true }
                    }
                )
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.25), value: mostraErroreEmail)
        .onChange(of: email) { _, _ in mostraErroreEmail = false }
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
    NavigationStack {
        RegistrationView(showLogin: .constant(false))
    }
    .modelContainer(for: [User.self, Build.self], inMemory: true)
}
