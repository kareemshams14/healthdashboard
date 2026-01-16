//
//  APIClient.swift
//  JoeyMed Patient Tools
//

import Foundation

class APIClient {
    static let shared = APIClient()

    private let baseURL: String = {
        #if DEBUG
        return "https://api-dev.joeymed.com"
        #else
        return "https://api.joeymed.com"
        #endif
    }()

    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE, PATCH
    }

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Add auth token if available
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JoeyMed-iOS/1.0", forHTTPHeaderField: "User-Agent")

        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Encode body if provided
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.unknown(statusCode: httpResponse.statusCode)
        }
    }

    private func getAuthToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.joeymed.patient",
            kSecAttrAccount as String: "authToken",
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

    enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case unauthorized
        case notFound
        case serverError
        case unknown(statusCode: Int)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .unauthorized:
                return "Unauthorized. Please log in again."
            case .notFound:
                return "Resource not found"
            case .serverError:
                return "Server error. Please try again later."
            case .unknown(let code):
                return "Unknown error (Status: \(code))"
            }
        }
    }
}
