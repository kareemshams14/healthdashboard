//
//  Config.swift
//  JoeyMed Patient Tools
//
//  Configuration settings for the app
//

import Foundation

enum Config {
    // MARK: - API Configuration

    static let apiBaseURL: String = {
        #if DEBUG
        return "https://api-dev.joeymed.com"
        #else
        return "https://api.joeymed.com"
        #endif
    }()

    // MARK: - GHL Configuration

    static let ghlAPIKey: String = {
        // TODO: Replace with your actual GHL API key or fetch from secure storage
        return ProcessInfo.processInfo.environment["GHL_API_KEY"] ?? ""
    }()

    static let ghlLocationId: String = {
        // TODO: Replace with your GHL location ID
        return ProcessInfo.processInfo.environment["GHL_LOCATION_ID"] ?? ""
    }()

    // MARK: - Stripe Configuration

    static let stripePublishableKey: String = {
        #if DEBUG
        return "pk_test_YOUR_TEST_KEY" // TODO: Add your test key
        #else
        return "pk_live_YOUR_LIVE_KEY" // TODO: Add your live key
        #endif
    }()

    // MARK: - App Configuration

    static let appVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }()

    static let buildNumber: String = {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }()

    // MARK: - Feature Flags

    enum Features {
        static let enableHealthKitIntegration = false
        static let enablePushNotifications = true
        static let enableBiometricAuth = true
        static let enableTelehealth = true
    }

    // MARK: - Analytics

    enum Analytics {
        static let enableCrashReporting = true
        static let enableUsageAnalytics = true
    }
}
