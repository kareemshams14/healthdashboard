//
//  LoginView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color("PrimaryBlue"))
                        .padding(.top, 60)

                    Text("JoeyMed")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Patient Portal")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    // Login Form
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        Button(action: login) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 50)
                        .background(Color("PrimaryBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isLoading || email.isEmpty || password.isEmpty)

                        HStack {
                            Button("Forgot Password?") {
                                // TODO: Implement forgot password
                            }
                            .font(.subheadline)
                            .foregroundColor(Color("PrimaryBlue"))

                            Spacer()

                            NavigationLink(destination: SignUpView()) {
                                Text("Sign Up")
                                    .font(.subheadline)
                                    .foregroundColor(Color("PrimaryBlue"))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 40)

                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func login() {
        isLoading = true

        Task {
            do {
                try await authManager.login(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }

            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager.shared)
}
