//
//  Message.swift
//  JoeyMed Patient Tools
//

import Foundation

struct Message: Codable, Identifiable {
    let id: String
    var conversationId: String
    var senderId: String
    var senderName: String
    var senderType: SenderType
    var content: String
    var timestamp: Date
    var isRead: Bool
    var attachments: [Attachment]?

    // GHL conversation ID
    var ghlMessageId: String?

    enum SenderType: String, Codable {
        case patient = "Patient"
        case provider = "Provider"
        case staff = "Staff"
        case system = "System"
    }
}

struct Conversation: Codable, Identifiable {
    let id: String
    var patientId: String
    var subject: String
    var participants: [Participant]
    var lastMessage: Message?
    var unreadCount: Int
    var createdAt: Date
    var updatedAt: Date

    struct Participant: Codable {
        let id: String
        let name: String
        let type: Message.SenderType
    }
}

struct Attachment: Codable, Identifiable {
    let id: String
    var fileName: String
    var fileSize: Int
    var fileType: String
    var url: String
}
