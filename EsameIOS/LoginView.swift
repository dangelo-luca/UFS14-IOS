import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var impostazioni = UserSettings.shared

    private enum Campo { case email, password }

    @State private var email = ""
    @State private var password = ""
    @State private var mostraErrore = false
    @FocusState private var focus: Campo?

    @Binding var showLogin: Bool
    var onSuccess: (() -> Void)? = nil

    private var puoAccedere: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AuthHeader(
                    title: "Bentornato",
                    subtitle: "Accedi per ritrovare le tue build salvate."
                )
                .padding(.top, 32)

                AuthFieldGroup {
                    AuthField(placeholder: "Email",
                              text: $email,
                              keyboard: .emailAddress,
                              contentType: .username,
                              capitalization: .never)
                        .focused($focus, equals: .email)
                        .onSubmit { focus = .password }

                    AuthDivider()

                    AuthField(placeholder: "Password",
                              text: $password,
                              isSecure: true,
                              contentType: .password,
                              submitLabel: .go)
                        .focused($focus, equals: .password)
                        .onSubmit { if puoAccedere { effettuaLogin() } }
                }

                if mostraErrore {
                    AuthErrorLabel(message: "Email o password non corretti.")
                }

                AuthPrimaryButton(title: "Accedi", isEnabled: puoAccedere) {
                    effettuaLogin()
                }

                AuthSwitchLink(
                    question: "Non hai un account?",
                    action: "Registrati",
                    onTap: {
                        withAnimation { showLogin = false }
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
        .animation(.easeInOut(duration: 0.25), value: mostraErrore)
        .onChange(of: email) { _, _ in mostraErrore = false }
        .onChange(of: password) { _, _ in mostraErrore = false }
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
    NavigationStack {
        LoginView(showLogin: .constant(true))
    }
    .modelContainer(for: [User.self, Build.self], inMemory: true)
}
