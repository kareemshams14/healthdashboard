//
//  StripeService.swift
//  JoeyMed Patient Tools
//
//  Integration with Stripe for payments and renewals
//

import Foundation
import PassKit

class StripeService: NSObject {
    static let shared = StripeService()

    private let stripePublishableKey: String = {
        #if DEBUG
        return "pk_test_YOUR_TEST_KEY" // TODO: Add your test key
        #else
        return "pk_live_YOUR_LIVE_KEY" // TODO: Add your live key
        #endif
    }()

    // MARK: - Payment Methods

    func createPaymentIntent(amount: Int, currency: String = "usd") async throws -> PaymentIntent {
        // Call your backend to create a payment intent
        let body = CreatePaymentIntentRequest(amount: amount, currency: currency)

        let response: PaymentIntent = try await APIClient.shared.request(
            endpoint: "/payments/create-intent",
            method: .POST,
            body: body
        )

        return response
    }

    func confirmPayment(paymentIntentId: String, paymentMethodId: String) async throws -> PaymentIntent {
        let body = ConfirmPaymentRequest(
            paymentIntentId: paymentIntentId,
            paymentMethodId: paymentMethodId
        )

        let response: PaymentIntent = try await APIClient.shared.request(
            endpoint: "/payments/confirm",
            method: .POST,
            body: body
        )

        return response
    }

    // MARK: - Customer Methods

    func fetchPaymentMethods() async throws -> [PaymentMethod] {
        let response: PaymentMethodsResponse = try await APIClient.shared.request(
            endpoint: "/payments/methods",
            method: .GET
        )

        return response.paymentMethods
    }

    func addPaymentMethod(cardNumber: String, expMonth: Int, expYear: Int, cvc: String) async throws -> PaymentMethod {
        let body = AddPaymentMethodRequest(
            cardNumber: cardNumber,
            expMonth: expMonth,
            expYear: expYear,
            cvc: cvc
        )

        let response: PaymentMethod = try await APIClient.shared.request(
            endpoint: "/payments/methods",
            method: .POST,
            body: body
        )

        return response
    }

    func deletePaymentMethod(paymentMethodId: String) async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/payments/methods/\(paymentMethodId)",
            method: .DELETE
        )
    }

    func setDefaultPaymentMethod(paymentMethodId: String) async throws {
        let body = SetDefaultPaymentMethodRequest(paymentMethodId: paymentMethodId)

        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/payments/methods/default",
            method: .PUT,
            body: body
        )
    }

    // MARK: - Subscription Methods

    func fetchSubscription() async throws -> Subscription? {
        do {
            let response: Subscription = try await APIClient.shared.request(
                endpoint: "/payments/subscription",
                method: .GET
            )
            return response
        } catch {
            return nil
        }
    }

    func createSubscription(priceId: String, paymentMethodId: String) async throws -> Subscription {
        let body = CreateSubscriptionRequest(
            priceId: priceId,
            paymentMethodId: paymentMethodId
        )

        let response: Subscription = try await APIClient.shared.request(
            endpoint: "/payments/subscription",
            method: .POST,
            body: body
        )

        return response
    }

    func cancelSubscription(subscriptionId: String) async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/payments/subscription/\(subscriptionId)",
            method: .DELETE
        )
    }

    // MARK: - Renewal Payment

    func processRenewalPayment(renewalId: String, paymentMethodId: String) async throws -> PaymentResult {
        let body = RenewalPaymentRequest(
            renewalId: renewalId,
            paymentMethodId: paymentMethodId
        )

        let response: PaymentResult = try await APIClient.shared.request(
            endpoint: "/renewals/\(renewalId)/payment",
            method: .POST,
            body: body
        )

        return response
    }

    // MARK: - Invoice Methods

    func fetchInvoices() async throws -> [Invoice] {
        let response: InvoicesResponse = try await APIClient.shared.request(
            endpoint: "/payments/invoices",
            method: .GET
        )

        return response.invoices
    }
}

// MARK: - Stripe Models

struct PaymentIntent: Codable {
    let id: String
    let amount: Int
    let currency: String
    let status: String
    let clientSecret: String?
}

struct PaymentMethod: Codable, Identifiable {
    let id: String
    let type: String
    let card: Card?
    let isDefault: Bool?

    struct Card: Codable {
        let brand: String
        let last4: String
        let expMonth: Int
        let expYear: Int
    }
}

struct Subscription: Codable {
    let id: String
    let status: String
    let currentPeriodEnd: Date
    let cancelAtPeriodEnd: Bool
    let amount: Int
    let currency: String
}

struct Invoice: Codable, Identifiable {
    let id: String
    let amount: Int
    let currency: String
    let status: String
    let date: Date
    let invoiceUrl: String?
}

struct PaymentResult: Codable {
    let success: Bool
    let paymentIntentId: String?
    let message: String?
}

// MARK: - Request Models

struct CreatePaymentIntentRequest: Codable {
    let amount: Int
    let currency: String
}

struct ConfirmPaymentRequest: Codable {
    let paymentIntentId: String
    let paymentMethodId: String
}

struct AddPaymentMethodRequest: Codable {
    let cardNumber: String
    let expMonth: Int
    let expYear: Int
    let cvc: String
}

struct SetDefaultPaymentMethodRequest: Codable {
    let paymentMethodId: String
}

struct CreateSubscriptionRequest: Codable {
    let priceId: String
    let paymentMethodId: String
}

struct RenewalPaymentRequest: Codable {
    let renewalId: String
    let paymentMethodId: String
}

// MARK: - Response Models

struct PaymentMethodsResponse: Codable {
    let paymentMethods: [PaymentMethod]
}

struct InvoicesResponse: Codable {
    let invoices: [Invoice]
}

struct EmptyResponse: Codable {}
