//
//  PaymentView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var patientStore: PatientStore
    let renewalRequest: RenewalRequest

    @State private var selectedPaymentMethod: PaymentMethod?
    @State private var showAddCard = false
    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Amount Due
                VStack(spacing: 8) {
                    Text("Amount Due")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("$149.00")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.green)

                    Text("Prescription Renewal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(16)

                // Payment Methods
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Payment Method")
                            .font(.headline)

                        Spacer()

                        Button(action: { showAddCard = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Card")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                    }

                    if patientStore.paymentMethods.isEmpty {
                        Text("No payment methods on file")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(patientStore.paymentMethods) { method in
                            PaymentMethodCard(
                                method: method,
                                isSelected: selectedPaymentMethod?.id == method.id,
                                onTap: {
                                    selectedPaymentMethod = method
                                }
                            )
                        }
                    }
                }

                // Pay Button
                Button(action: processPayment) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                    } else {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Pay Now")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 50)
                .background(selectedPaymentMethod != nil ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(selectedPaymentMethod == nil || isProcessing)

                // Security Notice
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.green)
                    Text("Secured by Stripe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCard) {
            AddPaymentMethodView()
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") {}
        } message: {
            Text("Payment processed successfully!")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .task {
            await patientStore.loadPaymentMethods()
        }
    }

    private func processPayment() {
        guard let paymentMethod = selectedPaymentMethod else { return }

        isProcessing = true

        Task {
            do {
                try await patientStore.processRenewalPayment(
                    renewalId: renewalRequest.id,
                    paymentMethodId: paymentMethod.id
                )

                await MainActor.run {
                    isProcessing = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isProcessing = false
                }
            }
        }
    }
}

struct PaymentMethodCard: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: cardIcon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .primary)

                VStack(alignment: .leading, spacing: 4) {
                    if let card = method.card {
                        Text("\(card.brand.capitalized) •••• \(card.last4)")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text("Expires \(card.expMonth)/\(card.expYear)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var cardIcon: String {
        guard let card = method.card else { return "creditcard.fill" }

        switch card.brand.lowercased() {
        case "visa":
            return "creditcard.fill"
        case "mastercard":
            return "creditcard.fill"
        case "amex":
            return "creditcard.fill"
        default:
            return "creditcard.fill"
        }
    }
}

struct AddPaymentMethodView: View {
    @Environment(\.dismiss) var dismiss
    @State private var cardNumber = ""
    @State private var expMonth = ""
    @State private var expYear = ""
    @State private var cvc = ""
    @State private var isAdding = false

    var body: some View {
        NavigationView {
            Form {
                Section("Card Information") {
                    TextField("Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)

                    HStack {
                        TextField("MM", text: $expMonth)
                            .keyboardType(.numberPad)
                            .frame(width: 60)

                        Text("/")

                        TextField("YY", text: $expYear)
                            .keyboardType(.numberPad)
                            .frame(width: 60)

                        Spacer()

                        TextField("CVC", text: $cvc)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                    }
                }
            }
            .navigationTitle("Add Payment Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        // TODO: Implement add card
                        dismiss()
                    }
                    .disabled(cardNumber.isEmpty || expMonth.isEmpty || expYear.isEmpty || cvc.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        PaymentView(renewalRequest: RenewalRequest(
            id: "r1",
            prescriptionId: "p1",
            patientId: "pat1",
            requestDate: Date(),
            status: .paymentRequired
        ))
        .environmentObject(PatientStore.shared)
    }
}
