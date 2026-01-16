//
//  PatientStore.swift
//  JoeyMed Patient Tools
//

import Foundation

class PatientStore: ObservableObject {
    static let shared = PatientStore()

    @Published var prescriptions: [Prescription] = []
    @Published var appointments: [Appointment] = []
    @Published var conversations: [Conversation] = []
    @Published var paymentMethods: [PaymentMethod] = []
    @Published var invoices: [Invoice] = []
    @Published var renewalRequests: [RenewalRequest] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() {}

    // MARK: - Data Fetching

    func loadAllData() async {
        await MainActor.run { isLoading = true }

        async let prescriptionsTask = loadPrescriptions()
        async let appointmentsTask = loadAppointments()
        async let conversationsTask = loadConversations()
        async let paymentMethodsTask = loadPaymentMethods()

        await prescriptionsTask
        await appointmentsTask
        await conversationsTask
        await paymentMethodsTask

        await MainActor.run { isLoading = false }
    }

    func loadPrescriptions() async {
        do {
            let response: [Prescription] = try await APIClient.shared.request(
                endpoint: "/prescriptions",
                method: .GET
            )

            await MainActor.run {
                self.prescriptions = response
            }
        } catch {
            await setError("Failed to load prescriptions: \(error.localizedDescription)")
        }
    }

    func loadAppointments() async {
        guard let patient = AuthenticationManager.shared.currentPatient,
              let ghlContactId = patient.ghlContactId else {
            return
        }

        do {
            let appointments = try await GHLService.shared.fetchAppointments(contactId: ghlContactId)

            await MainActor.run {
                self.appointments = appointments
            }
        } catch {
            await setError("Failed to load appointments: \(error.localizedDescription)")
        }
    }

    func loadConversations() async {
        guard let patient = AuthenticationManager.shared.currentPatient,
              let ghlContactId = patient.ghlContactId else {
            return
        }

        do {
            let conversations = try await GHLService.shared.fetchConversations(contactId: ghlContactId)

            await MainActor.run {
                self.conversations = conversations
            }
        } catch {
            await setError("Failed to load conversations: \(error.localizedDescription)")
        }
    }

    func loadPaymentMethods() async {
        do {
            let methods = try await StripeService.shared.fetchPaymentMethods()

            await MainActor.run {
                self.paymentMethods = methods
            }
        } catch {
            await setError("Failed to load payment methods: \(error.localizedDescription)")
        }
    }

    func loadInvoices() async {
        do {
            let invoices = try await StripeService.shared.fetchInvoices()

            await MainActor.run {
                self.invoices = invoices
            }
        } catch {
            await setError("Failed to load invoices: \(error.localizedDescription)")
        }
    }

    // MARK: - Renewal Requests

    func createRenewalRequest(prescriptionId: String, notes: String?) async throws -> RenewalRequest {
        let body = CreateRenewalRequest(prescriptionId: prescriptionId, notes: notes)

        let request: RenewalRequest = try await APIClient.shared.request(
            endpoint: "/renewals",
            method: .POST,
            body: body
        )

        await MainActor.run {
            self.renewalRequests.append(request)
        }

        return request
    }

    func processRenewalPayment(renewalId: String, paymentMethodId: String) async throws {
        let result = try await StripeService.shared.processRenewalPayment(
            renewalId: renewalId,
            paymentMethodId: paymentMethodId
        )

        if result.success {
            // Refresh data
            await loadPrescriptions()
            await loadInvoices()
        } else {
            throw PaymentError.paymentFailed(message: result.message ?? "Unknown error")
        }
    }

    // MARK: - Appointments

    func bookAppointment(
        calendarId: String,
        date: Date,
        type: Appointment.AppointmentType
    ) async throws -> Appointment {
        guard let patient = AuthenticationManager.shared.currentPatient,
              let ghlContactId = patient.ghlContactId else {
            throw AppointmentError.noContactId
        }

        let appointment = try await GHLService.shared.createAppointment(
            contactId: ghlContactId,
            calendarId: calendarId,
            date: date,
            appointmentType: type
        )

        await MainActor.run {
            self.appointments.append(appointment)
        }

        return appointment
    }

    func cancelAppointment(appointmentId: String) async throws {
        guard let appointment = appointments.first(where: { $0.id == appointmentId }),
              let ghlEventId = appointment.ghlEventId else {
            throw AppointmentError.appointmentNotFound
        }

        try await GHLService.shared.cancelAppointment(appointmentId: ghlEventId)

        await MainActor.run {
            self.appointments.removeAll { $0.id == appointmentId }
        }
    }

    // MARK: - Messaging

    func sendMessage(conversationId: String, message: String) async throws {
        guard let patient = AuthenticationManager.shared.currentPatient,
              let ghlContactId = patient.ghlContactId else {
            throw MessagingError.noContactId
        }

        let sentMessage = try await GHLService.shared.sendMessage(
            conversationId: conversationId,
            message: message,
            contactId: ghlContactId
        )

        await MainActor.run {
            if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
                conversations[index].lastMessage = sentMessage
                conversations[index].updatedAt = Date()
            }
        }
    }

    func startNewConversation(message: String) async throws -> Conversation {
        guard let patient = AuthenticationManager.shared.currentPatient,
              let ghlContactId = patient.ghlContactId else {
            throw MessagingError.noContactId
        }

        let conversation = try await GHLService.shared.createConversation(
            contactId: ghlContactId,
            message: message
        )

        await MainActor.run {
            self.conversations.insert(conversation, at: 0)
        }

        return conversation
    }

    // MARK: - Helper Methods

    private func setError(_ message: String) async {
        await MainActor.run {
            self.errorMessage = message
        }
    }

    func clearError() {
        errorMessage = nil
    }

    enum PaymentError: LocalizedError {
        case paymentFailed(message: String)

        var errorDescription: String? {
            switch self {
            case .paymentFailed(let message):
                return message
            }
        }
    }

    enum AppointmentError: LocalizedError {
        case noContactId
        case appointmentNotFound

        var errorDescription: String? {
            switch self {
            case .noContactId:
                return "No GHL contact ID found"
            case .appointmentNotFound:
                return "Appointment not found"
            }
        }
    }

    enum MessagingError: LocalizedError {
        case noContactId

        var errorDescription: String? {
            switch self {
            case .noContactId:
                return "No GHL contact ID found"
            }
        }
    }
}

struct CreateRenewalRequest: Codable {
    let prescriptionId: String
    let notes: String?
}
