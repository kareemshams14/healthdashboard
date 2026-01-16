//
//  JoeyMedPatientApp.swift
//  JoeyMed Patient Tools
//
//  Advanced iOS app for joeymed.com patients
//

import SwiftUI

@main
struct JoeyMedPatientApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var patientStore = PatientStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(patientStore)
                .preferredColorScheme(.light)
        }
    }
}
