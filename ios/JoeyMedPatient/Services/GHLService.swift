//
//  GHLService.swift
//  JoeyMed Patient Tools
//
//  Integration with GoHighLevel CRM for calendar and communication
//

import Foundation

class GHLService {
    static let shared = GHLService()

    private let ghlAPIKey: String = {
        // TODO: Store this securely in your backend and fetch it, or use iOS app config
        return ProcessInfo.processInfo.environment["GHL_API_KEY"] ?? ""
    }()

    private let ghlBaseURL = "https://rest.gohighlevel.com/v1"

    // MARK: - Calendar Methods

    func fetchAppointments(contactId: String) async throws -> [Appointment] {
        let endpoint = "/appointments/"

        let params: [String: Any] = [
            "contactId": contactId,
            "startDate": Date().addingTimeInterval(-30 * 24 * 3600), // Last 30 days
            "endDate": Date().addingTimeInterval(90 * 24 * 3600) // Next 90 days
        ]

        let appointments: GHLAppointmentsResponse = try await makeGHLRequest(
            endpoint: endpoint,
            method: .GET,
            queryParams: params
        )

        return appointments.appointments.map { $0.toAppointment() }
    }

    func createAppointment(
        contactId: String,
        calendarId: String,
        date: Date,
        appointmentType: Appointment.AppointmentType
    ) async throws -> Appointment {
        let endpoint = "/appointments/"

        let body: [String: Any] = [
            "calendarId": calendarId,
            "contactId": contactId,
            "startTime": ISO8601DateFormatter().string(from: date),
            "title": appointmentType.rawValue,
            "appointmentStatus": "confirmed"
        ]

        let response: GHLAppointment = try await makeGHLRequest(
            endpoint: endpoint,
            method: .POST,
            body: body
        )

        return response.toAppointment()
    }

    func updateAppointment(appointmentId: String, status: Appointment.AppointmentStatus) async throws {
        let endpoint = "/appointments/\(appointmentId)"

        let body: [String: Any] = [
            "appointmentStatus": status.toGHLStatus()
        ]

        let _: GHLAppointment = try await makeGHLRequest(
            endpoint: endpoint,
            method: .PUT,
            body: body
        )
    }

    func cancelAppointment(appointmentId: String) async throws {
        let endpoint = "/appointments/\(appointmentId)"

        try await makeGHLRequest(
            endpoint: endpoint,
            method: .DELETE,
            body: nil as String?
        )
    }

    // MARK: - Messaging Methods

    func fetchConversations(contactId: String) async throws -> [Conversation] {
        let endpoint = "/conversations/search"

        let params: [String: Any] = [
            "contactId": contactId
        ]

        let response: GHLConversationsResponse = try await makeGHLRequest(
            endpoint: endpoint,
            method: .GET,
            queryParams: params
        )

        return response.conversations.map { $0.toConversation() }
    }

    func fetchMessages(conversationId: String) async throws -> [Message] {
        let endpoint = "/conversations/\(conversationId)/messages"

        let response: GHLMessagesResponse = try await makeGHLRequest(
            endpoint: endpoint,
            method: .GET
        )

        return response.messages.map { $0.toMessage() }
    }

    func sendMessage(conversationId: String, message: String, contactId: String) async throws -> Message {
        let endpoint = "/conversations/messages"

        let body: [String: Any] = [
            "type": "SMS", // or "Email" depending on preference
            "contactId": contactId,
            "conversationId": conversationId,
            "message": message
        ]

        let response: GHLMessage = try await makeGHLRequest(
            endpoint: endpoint,
            method: .POST,
            body: body
        )

        return response.toMessage()
    }

    func createConversation(contactId: String, message: String) async throws -> Conversation {
        let endpoint = "/conversations/"

        let body: [String: Any] = [
            "contactId": contactId,
            "type": "SMS",
            "message": message
        ]

        let response: GHLConversation = try await makeGHLRequest(
            endpoint: endpoint,
            method: .POST,
            body: body
        )

        return response.toConversation()
    }

    // MARK: - Contact Methods

    func updateContact(contactId: String, data: [String: Any]) async throws {
        let endpoint = "/contacts/\(contactId)"

        let _: GHLContact = try await makeGHLRequest(
            endpoint: endpoint,
            method: .PUT,
            body: data
        )
    }

    // MARK: - Helper Methods

    private func makeGHLRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        queryParams: [String: Any]? = nil,
        body: Encodable? = nil
    ) async throws -> T {
        var urlComponents = URLComponents(string: ghlBaseURL + endpoint)

        if let queryParams = queryParams {
            urlComponents?.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }

        guard let url = urlComponents?.url else {
            throw GHLError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(ghlAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GHLError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw GHLError.requestFailed(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE
    }

    enum GHLError: LocalizedError {
        case invalidURL
        case invalidResponse
        case requestFailed(statusCode: Int)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid GHL URL"
            case .invalidResponse:
                return "Invalid response from GHL"
            case .requestFailed(let code):
                return "GHL request failed (Status: \(code))"
            }
        }
    }
}

// MARK: - GHL Response Models

struct GHLAppointmentsResponse: Codable {
    let appointments: [GHLAppointment]
}

struct GHLAppointment: Codable {
    let id: String
    let calendarId: String
    let contactId: String
    let title: String
    let startTime: String
    let endTime: String
    let appointmentStatus: String

    func toAppointment() -> Appointment {
        let dateFormatter = ISO8601DateFormatter()
        let startDate = dateFormatter.date(from: startTime) ?? Date()
        let endDate = dateFormatter.date(from: endTime) ?? Date()
        let duration = Int(endDate.timeIntervalSince(startDate) / 60)

        return Appointment(
            id: id,
            patientId: contactId,
            providerName: "JoeyMed Provider",
            appointmentType: .consultation,
            scheduledDate: startDate,
            duration: duration,
            status: .scheduled,
            location: .office,
            ghlEventId: id
        )
    }
}

struct GHLConversationsResponse: Codable {
    let conversations: [GHLConversation]
}

struct GHLConversation: Codable {
    let id: String
    let contactId: String
    let lastMessageBody: String?
    let lastMessageDate: String?
    let unreadCount: Int?

    func toConversation() -> Conversation {
        let dateFormatter = ISO8601DateFormatter()
        let updatedDate = lastMessageDate.flatMap { dateFormatter.date(from: $0) } ?? Date()

        return Conversation(
            id: id,
            patientId: contactId,
            subject: "Conversation",
            participants: [],
            unreadCount: unreadCount ?? 0,
            createdAt: updatedDate,
            updatedAt: updatedDate
        )
    }
}

struct GHLMessagesResponse: Codable {
    let messages: [GHLMessage]
}

struct GHLMessage: Codable {
    let id: String
    let conversationId: String
    let body: String
    let dateAdded: String
    let direction: String

    func toMessage() -> Message {
        let dateFormatter = ISO8601DateFormatter()
        let timestamp = dateFormatter.date(from: dateAdded) ?? Date()

        return Message(
            id: id,
            conversationId: conversationId,
            senderId: direction == "inbound" ? "patient" : "provider",
            senderName: direction == "inbound" ? "You" : "JoeyMed",
            senderType: direction == "inbound" ? .patient : .provider,
            content: body,
            timestamp: timestamp,
            isRead: true,
            ghlMessageId: id
        )
    }
}

struct GHLContact: Codable {
    let id: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let phone: String?
}

extension Appointment.AppointmentStatus {
    func toGHLStatus() -> String {
        switch self {
        case .scheduled: return "scheduled"
        case .confirmed: return "confirmed"
        case .completed: return "showed"
        case .cancelled: return "cancelled"
        case .noShow: return "noshow"
        default: return "scheduled"
        }
    }
}
