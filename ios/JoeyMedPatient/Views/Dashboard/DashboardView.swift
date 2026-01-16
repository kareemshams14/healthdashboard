//
//  DashboardView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var patientStore: PatientStore

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    welcomeHeader

                    // Quick Actions
                    quickActionsSection

                    // Upcoming Appointments
                    upcomingAppointmentsSection

                    // Active Prescriptions
                    activePrescriptionsSection

                    // Unread Messages
                    unreadMessagesSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {}) {
                            Label("Profile", systemImage: "person.fill")
                        }

                        Button(action: {}) {
                            Label("Settings", systemImage: "gearshape.fill")
                        }

                        Divider()

                        Button(role: .destructive, action: { authManager.logout() }) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .refreshable {
                await patientStore.loadAllData()
            }
        }
    }

    private var welcomeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let patient = authManager.currentPatient {
                    Text(patient.firstName)
                        .font(.title)
                        .fontWeight(.bold)
                }
            }

            Spacer()

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 50))
                .foregroundColor(Color("PrimaryBlue"))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickActionButton(
                    icon: "calendar.badge.plus",
                    title: "Book Appointment",
                    color: .blue
                )

                QuickActionButton(
                    icon: "arrow.clockwise",
                    title: "Request Renewal",
                    color: .green
                )

                QuickActionButton(
                    icon: "message.fill",
                    title: "Message Provider",
                    color: .purple
                )

                QuickActionButton(
                    icon: "function",
                    title: "Use Tools",
                    color: .orange
                )
            }
        }
    }

    private var upcomingAppointmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Appointments")
                    .font(.headline)

                Spacer()

                NavigationLink(destination: AppointmentsView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            if patientStore.appointments.isEmpty {
                emptyStateCard(icon: "calendar", message: "No upcoming appointments")
            } else {
                ForEach(patientStore.appointments.prefix(2)) { appointment in
                    AppointmentPreviewCard(appointment: appointment)
                }
            }
        }
    }

    private var activePrescriptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Prescriptions")
                    .font(.headline)

                Spacer()

                NavigationLink(destination: PrescriptionsView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            if patientStore.prescriptions.isEmpty {
                emptyStateCard(icon: "pills.fill", message: "No active prescriptions")
            } else {
                ForEach(patientStore.prescriptions.filter { $0.status == .active }.prefix(2)) { prescription in
                    PrescriptionPreviewCard(prescription: prescription)
                }
            }
        }
    }

    private var unreadMessagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Messages")
                    .font(.headline)

                if patientStore.conversations.contains(where: { $0.unreadCount > 0 }) {
                    Text("\(patientStore.conversations.reduce(0) { $0 + $1.unreadCount })")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()

                NavigationLink(destination: MessagesView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            if patientStore.conversations.isEmpty {
                emptyStateCard(icon: "message.fill", message: "No messages")
            } else {
                ForEach(patientStore.conversations.prefix(2)) { conversation in
                    ConversationPreviewCard(conversation: conversation)
                }
            }
        }
    }

    private func emptyStateCard(icon: String, message: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct AppointmentPreviewCard: View {
    let appointment: Appointment

    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Text(appointment.scheduledDate.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)

                Text(appointment.scheduledDate.formatted(.dateTime.day()))
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(width: 60)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.appointmentType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("Dr. \(appointment.providerName)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                    Text(appointment.scheduledDate.formatted(.dateTime.hour().minute()))
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct PrescriptionPreviewCard: View {
    let prescription: Prescription

    var body: some View {
        HStack {
            Image(systemName: "pills.fill")
                .font(.title3)
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 4) {
                Text(prescription.medicationName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(prescription.dosage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if prescription.isExpiringSoon {
                Text("Expiring Soon")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ConversationPreviewCard: View {
    let conversation: Conversation

    var body: some View {
        HStack {
            Image(systemName: "message.fill")
                .font(.title3)
                .foregroundColor(.purple)

            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.subject)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(PatientStore.shared)
}
