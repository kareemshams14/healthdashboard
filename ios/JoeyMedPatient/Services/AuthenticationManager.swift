//
//  AuthenticationManager.swift
//  JoeyMed Patient Tools
//

import Foundation
import Security

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()

    @Published var isAuthenticated = false
    @Published var currentPatient: Patient?

    private let keychainService = "com.joeymed.patient"
    private let tokenKey = "authToken"

    private init() {
        checkAuthStatus()
    }

    func login(email: String, password: String) async throws {
        // Call your backend API to authenticate
        let loginData = LoginRequest(email: email, password: password)

        let response = try await APIClient.shared.request(
            endpoint: "/auth/login",
            method: .POST,
            body: loginData
        ) as LoginResponse

        // Store token securely in keychain
        try saveToken(response.token)

        // Fetch patient data
        await fetchCurrentPatient()

        await MainActor.run {
            self.isAuthenticated = true
        }
    }

    func logout() {
        deleteToken()
        currentPatient = nil
        isAuthenticated = false
    }

    func fetchCurrentPatient() async {
        do {
            let patient: Patient = try await APIClient.shared.request(
                endpoint: "/patient/me",
                method: .GET
            )

            await MainActor.run {
                self.currentPatient = patient
            }
        } catch {
            print("Failed to fetch patient: \(error)")
        }
    }

    private func checkAuthStatus() {
        if let _ = getToken() {
            isAuthenticated = true
            Task {
                await fetchCurrentPatient()
            }
        }
    }

    // MARK: - Keychain Helper Methods

    private func saveToken(_ token: String) throws {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }

    private func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    private func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenKey
        ]

        SecItemDelete(query as CFDictionary)
    }

    enum KeychainError: Error {
        case saveFailed
        case retrieveFailed
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let patient: Patient
}
