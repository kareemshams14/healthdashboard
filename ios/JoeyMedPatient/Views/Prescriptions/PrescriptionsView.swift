//
//  PrescriptionsView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct PrescriptionsView: View {
    @EnvironmentObject var patientStore: PatientStore
    @State private var showRenewalRequest = false
    @State private var selectedPrescription: Prescription?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if patientStore.prescriptions.isEmpty {
                        emptyStateView
                    } else {
                        // Active Prescriptions
                        activePrescriptionsSection

                        // Renewal Requests
                        if !patientStore.renewalRequests.isEmpty {
                            renewalRequestsSection
                        }

                        // Expired/Inactive
                        inactivePrescriptionsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Prescriptions")
            .refreshable {
                await patientStore.loadPrescriptions()
            }
            .sheet(isPresented: $showRenewalRequest) {
                if let prescription = selectedPrescription {
                    RenewalRequestView(prescription: prescription)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "pills.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding(.top, 60)

            Text("No Prescriptions")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Your prescriptions will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var activePrescriptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Prescriptions")
                .font(.headline)

            ForEach(patientStore.prescriptions.filter { $0.status == .active }) { prescription in
                PrescriptionCard(
                    prescription: prescription,
                    onRenewalTap: {
                        selectedPrescription = prescription
                        showRenewalRequest = true
                    }
                )
            }
        }
    }

    private var renewalRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Renewal Requests")
                .font(.headline)

            ForEach(patientStore.renewalRequests) { request in
                RenewalRequestCard(request: request)
            }
        }
    }

    private var inactivePrescriptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inactive")
                .font(.headline)

            ForEach(patientStore.prescriptions.filter { $0.status != .active }) { prescription in
                PrescriptionCard(
                    prescription: prescription,
                    onRenewalTap: nil
                )
            }
        }
    }
}

struct PrescriptionCard: View {
    let prescription: Prescription
    let onRenewalTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(prescription.medicationName)
                        .font(.headline)

                    Text("\(prescription.dosage) - \(prescription.frequency)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                StatusBadge(status: prescription.status)
            }

            Divider()

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prescribed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(prescription.prescribedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .fontWeight(.medium)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Expires")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(prescription.expirationDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(prescription.isExpiringSoon ? .orange : .primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Refills")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(prescription.refillsRemaining)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }

            if prescription.isExpiringSoon && prescription.status == .active, let onRenewalTap = onRenewalTap {
                Button(action: onRenewalTap) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Request Renewal")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }

            if let instructions = prescription.instructions {
                Text(instructions)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatusBadge: View {
    let status: Prescription.PrescriptionStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }

    private var statusColor: Color {
        switch status {
        case .active:
            return .green
        case .expired:
            return .red
        case .renewalRequested, .renewalApproved:
            return .blue
        case .discontinued:
            return .gray
        }
    }
}

struct RenewalRequestCard: View {
    let request: RenewalRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Renewal Request")
                        .font(.headline)

                    Text("Requested: \(request.requestDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(request.status.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(requestStatusColor(request.status).opacity(0.2))
                    .foregroundColor(requestStatusColor(request.status))
                    .cornerRadius(8)
            }

            if let notes = request.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if request.status == .paymentRequired {
                NavigationLink(destination: PaymentView(renewalRequest: request)) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text("Complete Payment")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func requestStatusColor(_ status: RenewalRequest.RequestStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .approved, .completed:
            return .green
        case .denied:
            return .red
        case .paymentRequired:
            return .blue
        }
    }
}

#Preview {
    PrescriptionsView()
        .environmentObject(PatientStore.shared)
}
