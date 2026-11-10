import SwiftUI

// MARK: - Intestazione

struct AuthHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.largeTitle.bold())
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Gruppo di campi (stile impostazioni di iOS)

struct AuthFieldGroup<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Campo

struct AuthField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var capitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(capitalization)
                    .autocorrectionDisabled(keyboard == .emailAddress)
            }
        }
        .textContentType(contentType)
        .padding(.horizontal, 16)
        .frame(height: 48)
    }
}

// Separatore tra i campi di un gruppo
struct AuthDivider: View {
    var body: some View {
        Divider().padding(.leading, 16)
    }
}

// MARK: - Link di cambio schermata

struct AuthSwitchLink: View {
    let question: String
    let action: String
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(question)
                .foregroundStyle(.secondary)
            Button(action, action: onTap)
        }
        .font(.subheadline)
    }
}
