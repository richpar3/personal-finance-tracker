import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: FinanceViewModel

    @State private var email       = ""
    @State private var password    = ""
    @State private var isSignUp    = false
    @State private var isLoading   = false
    @State private var errorMessage: String?

    private let accentGradient = LinearGradient(
        colors: [Color(red: 0.25, green: 0.40, blue: 0.95),
                 Color(red: 0.55, green: 0.25, blue: 0.90)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.06, blue: 0.10),
                         Color(red: 0.10, green: 0.12, blue: 0.22)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // ── Hero ──────────────────────────────────────────────
                    VStack(spacing: 14) {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(accentGradient)

                        Text("Finance Tracker")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.white)

                        Text(isSignUp ? "Create your account" : "Sign in to continue")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    .padding(.top, 80)
                    .padding(.bottom, 48)

                    // ── Form ──────────────────────────────────────────────
                    VStack(spacing: 20) {
                        fieldGroup(label: "Email", placeholder: "you@example.com",
                                   text: $email,
                                   keyboard: .emailAddress, secure: false)

                        fieldGroup(label: "Password", placeholder: "••••••••",
                                   text: $password,
                                   keyboard: .default, secure: true)

                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(Color(red: 1.0, green: 0.40, blue: 0.40))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 4)
                        }

                        // Submit button
                        Button { Task { await submit() } } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(accentGradient)
                                    .frame(height: 52)

                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, 28)

                    // ── Toggle ────────────────────────────────────────────
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { isSignUp.toggle() }
                        errorMessage = nil
                    } label: {
                        HStack(spacing: 4) {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .foregroundStyle(.white.opacity(0.55))
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(red: 0.50, green: 0.65, blue: 1.0))
                        }
                        .font(.subheadline)
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 48)
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func fieldGroup(label: String, placeholder: String,
                            text: Binding<String>,
                            keyboard: UIKeyboardType, secure: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.65))

            Group {
                if secure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
            )
        }
    }

    private func submit() async {
        isLoading    = true
        errorMessage = nil
        do {
            if isSignUp {
                try await viewModel.signUp(email: email, password: password)
            } else {
                try await viewModel.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
