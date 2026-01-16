//
//  Appointment.swift
//  JoeyMed Patient Tools
//

import Foundation

struct Appointment: Codable, Identifiable {
    let id: String
    var patientId: String
    var providerId: String?
    var providerName: String
    var appointmentType: AppointmentType
    var scheduledDate: Date
    var duration: Int // minutes
    var status: AppointmentStatus
    var location: AppointmentLocation
    var notes: String?

    // GHL calendar event ID
    var ghlEventId: String?

    enum AppointmentType: String, Codable, CaseIterable {
        case consultation = "Consultation"
        case followUp = "Follow-up"
        case weightCheck = "Weight Check"
        case telehealth = "Telehealth"
        case emergency = "Emergency"
    }

    enum AppointmentStatus: String, Codable {
        case scheduled = "Scheduled"
        case confirmed = "Confirmed"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
        case noShow = "No Show"
    }

    enum AppointmentLocation: String, Codable {
        case office = "Office"
        case telehealth = "Telehealth"
        case phone = "Phone"
    }
}
