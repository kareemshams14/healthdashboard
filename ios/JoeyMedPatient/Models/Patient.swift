//
//  Patient.swift
//  JoeyMed Patient Tools
//

import Foundation

struct Patient: Codable, Identifiable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var dateOfBirth: Date
    var gender: Gender

    // Health metrics
    var currentWeight: Double?
    var height: Double?
    var goalWeight: Double?
    var activityLevel: ActivityLevel?

    // GHL CRM ID for integration
    var ghlContactId: String?

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    enum Gender: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
        case preferNotToSay = "Prefer not to say"
    }

    enum ActivityLevel: String, Codable, CaseIterable {
        case sedentary = "Sedentary"
        case lightlyActive = "Lightly Active"
        case moderatelyActive = "Moderately Active"
        case veryActive = "Very Active"
        case extremelyActive = "Extremely Active"
    }
}
