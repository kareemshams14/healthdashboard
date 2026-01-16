//
//  Prescription.swift
//  JoeyMed Patient Tools
//

import Foundation

struct Prescription: Codable, Identifiable {
    let id: String
    var patientId: String
    var medicationName: String
    var dosage: String
    var frequency: String
    var prescribedDate: Date
    var expirationDate: Date
    var refillsRemaining: Int
    var status: PrescriptionStatus
    var instructions: String?

    var isExpiringSoon: Bool {
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return daysUntilExpiration <= 30 && daysUntilExpiration >= 0
    }

    var isExpired: Bool {
        expirationDate < Date()
    }

    enum PrescriptionStatus: String, Codable {
        case active = "Active"
        case expired = "Expired"
        case renewalRequested = "Renewal Requested"
        case renewalApproved = "Renewal Approved"
        case discontinued = "Discontinued"
    }
}

struct RenewalRequest: Codable, Identifiable {
    let id: String
    var prescriptionId: String
    var patientId: String
    var requestDate: Date
    var status: RequestStatus
    var notes: String?
    var paymentIntentId: String?

    enum RequestStatus: String, Codable {
        case pending = "Pending"
        case approved = "Approved"
        case denied = "Denied"
        case paymentRequired = "Payment Required"
        case completed = "Completed"
    }
}
