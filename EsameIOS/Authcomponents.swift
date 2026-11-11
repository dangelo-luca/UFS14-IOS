import SwiftUI

struct AuthHeader: View {
    var icon: String? = nil
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        LinearGradient(colors: [.pink, .pink.opacity(0.7)],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                    .shadow(color: .pink.opacity(0.3), radius: 10, y: 5)
                    .padding(.bottom, 8)
            }

            Text(title)
                .font(.largeTitle.bold())
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AuthFieldGroup<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct AuthField: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    var isSecure = false
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var capitalization: TextInputAutocapitalization = .sentences
    var submitLabel: SubmitLabel = .next

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
        .submitLabel(submitLabel)
        .padding(.horizontal, 16)
        .frame(height: 52)
    }
}

struct AuthDivider: View {
    var body: some View {
        Divider().padding(.leading, 16)
    }
}

struct AuthPrimaryButton: View {
    let title: LocalizedStringKey
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 14))
        .controlSize(.large)
        .tint(.pink)
        .disabled(!isEnabled)
    }
}

struct AuthErrorLabel: View {
    let message: LocalizedStringKey

    var body: some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.footnote)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

struct AuthSwitchLink: View {
    let question: LocalizedStringKey
    let action: LocalizedStringKey
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(question)
                .foregroundStyle(.secondary)
            Button(action, action: onTap)
                .fontWeight(.semibold)
                .tint(.pink)
        }
        .font(.subheadline)
    }
}
