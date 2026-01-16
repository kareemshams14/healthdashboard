//
//  RenewalRequestView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct RenewalRequestView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var patientStore: PatientStore
    let prescription: Prescription

    @State private var notes = ""
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Prescription Details") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(prescription.medicationName)
                            .font(.headline)

                        Text("\(prescription.dosage) - \(prescription.frequency)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Text("Expires:")
                                .foregroundColor(.secondary)
                            Text(prescription.expirationDate.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(prescription.isExpiringSoon ? .orange : .primary)
                        }
                        .font(.caption)

                        HStack {
                            Text("Refills remaining:")
                                .foregroundColor(.secondary)
                            Text("\(prescription.refillsRemaining)")
                        }
                        .font(.caption)
                    }
                }

                Section {
                    TextEditor(text: $notes)
                        .frame(height: 120)
                } header: {
                    Text("Notes (Optional)")
                } footer: {
                    Text("Add any notes or questions for your provider")
                }

                Section {
                    Text("Renewal Process")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 12) {
                        ProcessStep(number: 1, text: "Submit renewal request")
                        ProcessStep(number: 2, text: "Provider reviews and approves")
                        ProcessStep(number: 3, text: "Complete payment if required")
                        ProcessStep(number: 4, text: "Prescription is renewed")
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Request Renewal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        submitRequest()
                    }
                    .disabled(isSubmitting)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func submitRequest() {
        isSubmitting = true

        Task {
            do {
                _ = try await patientStore.createRenewalRequest(
                    prescriptionId: prescription.id,
                    notes: notes.isEmpty ? nil : notes
                )

                await MainActor.run {
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                isSubmitting = false
            }
        }
    }
}

struct ProcessStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 28, height: 28)

                Text("\(number)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    RenewalRequestView(prescription: Prescription(
        id: "1",
        patientId: "p1",
        medicationName: "Semaglutide",
        dosage: "0.5 mg",
        frequency: "Weekly",
        prescribedDate: Date().addingTimeInterval(-60 * 24 * 3600),
        expirationDate: Date().addingTimeInterval(30 * 24 * 3600),
        refillsRemaining: 2,
        status: .active
    ))
    .environmentObject(PatientStore.shared)
}
