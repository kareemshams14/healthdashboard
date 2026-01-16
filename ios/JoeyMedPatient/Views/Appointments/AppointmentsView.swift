//
//  AppointmentsView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct AppointmentsView: View {
    @EnvironmentObject var patientStore: PatientStore
    @State private var showBookAppointment = false
    @State private var selectedAppointment: Appointment?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if patientStore.appointments.isEmpty {
                        emptyStateView
                    } else {
                        // Upcoming Appointments
                        upcomingSection

                        // Past Appointments
                        pastSection
                    }
                }
                .padding()
            }
            .navigationTitle("Appointments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showBookAppointment = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showBookAppointment) {
                BookAppointmentView()
            }
            .sheet(item: $selectedAppointment) { appointment in
                AppointmentDetailView(appointment: appointment)
            }
            .refreshable {
                await patientStore.loadAppointments()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding(.top, 60)

            Text("No Appointments")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Book your first appointment")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: { showBookAppointment = true }) {
                Text("Book Appointment")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming")
                .font(.headline)

            let upcoming = patientStore.appointments.filter { $0.scheduledDate > Date() }

            if upcoming.isEmpty {
                Text("No upcoming appointments")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(upcoming) { appointment in
                    AppointmentCard(
                        appointment: appointment,
                        onTap: { selectedAppointment = appointment }
                    )
                }
            }
        }
    }

    private var pastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Past")
                .font(.headline)

            let past = patientStore.appointments.filter { $0.scheduledDate <= Date() }

            if past.isEmpty {
                Text("No past appointments")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(past) { appointment in
                    AppointmentCard(
                        appointment: appointment,
                        onTap: { selectedAppointment = appointment }
                    )
                }
            }
        }
    }
}

struct AppointmentCard: View {
    let appointment: Appointment
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Date Badge
                VStack {
                    Text(appointment.scheduledDate.formatted(.dateTime.month(.abbreviated)))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)

                    Text(appointment.scheduledDate.formatted(.dateTime.day()))
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(appointment.scheduledDate.formatted(.dateTime.weekday(.abbreviated)))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 60)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)

                // Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(appointment.appointmentType.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    HStack {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                        Text("Dr. \(appointment.providerName)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                        Text(appointment.scheduledDate.formatted(.dateTime.hour().minute()))
                        Text("•")
                        Text("\(appointment.duration) min")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: locationIcon(appointment.location))
                            .font(.caption2)
                        Text(appointment.location.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private func locationIcon(_ location: Appointment.AppointmentLocation) -> String {
        switch location {
        case .office:
            return "building.2.fill"
        case .telehealth:
            return "video.fill"
        case .phone:
            return "phone.fill"
        }
    }
}

struct AppointmentDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var patientStore: PatientStore
    let appointment: Appointment

    @State private var showCancelConfirmation = false
    @State private var isCancelling = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Date/Time
                    VStack(spacing: 8) {
                        Text(appointment.scheduledDate.formatted(.dateTime.month().day().year()))
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(appointment.scheduledDate.formatted(.dateTime.hour().minute()))
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)

                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(icon: "stethoscope", title: "Type", value: appointment.appointmentType.rawValue)
                        DetailRow(icon: "person.fill", title: "Provider", value: "Dr. \(appointment.providerName)")
                        DetailRow(icon: "clock.fill", title: "Duration", value: "\(appointment.duration) minutes")
                        DetailRow(icon: locationIcon(appointment.location), title: "Location", value: appointment.location.rawValue)
                        DetailRow(icon: "checkmark.circle.fill", title: "Status", value: appointment.status.rawValue)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)

                    if let notes = appointment.notes {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)

                            Text(notes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }

                    // Actions
                    if appointment.scheduledDate > Date() {
                        VStack(spacing: 12) {
                            if appointment.location == .telehealth {
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "video.fill")
                                        Text("Join Video Call")
                                    }
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }

                            Button(action: { showCancelConfirmation = true }) {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Cancel Appointment")
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Appointment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Cancel Appointment", isPresented: $showCancelConfirmation, titleVisibility: .visible) {
                Button("Cancel Appointment", role: .destructive) {
                    cancelAppointment()
                }
                Button("Keep Appointment", role: .cancel) {}
            } message: {
                Text("Are you sure you want to cancel this appointment?")
            }
        }
    }

    private func locationIcon(_ location: Appointment.AppointmentLocation) -> String {
        switch location {
        case .office:
            return "building.2.fill"
        case .telehealth:
            return "video.fill"
        case .phone:
            return "phone.fill"
        }
    }

    private func cancelAppointment() {
        isCancelling = true

        Task {
            do {
                try await patientStore.cancelAppointment(appointmentId: appointment.id)

                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Failed to cancel: \(error)")
                isCancelling = false
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(title)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

struct BookAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedType: Appointment.AppointmentType = .consultation
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            Form {
                Section("Appointment Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(Appointment.AppointmentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Date & Time") {
                    DatePicker("Select Date", selection: $selectedDate, in: Date()...)
                }
            }
            .navigationTitle("Book Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Book") {
                        // TODO: Implement booking
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AppointmentsView()
        .environmentObject(PatientStore.shared)
}
