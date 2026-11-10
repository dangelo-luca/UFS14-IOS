import SwiftUI
import SwiftData

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

#Preview {
    AuthView()
        .modelContainer(for: [User.self, Build.self], inMemory: true)
}
