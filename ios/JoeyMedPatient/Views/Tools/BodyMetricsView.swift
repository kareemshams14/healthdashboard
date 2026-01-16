//
//  BodyMetricsView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct BodyMetricsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Track comprehensive body measurements")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()

                // Placeholder for future body metrics tracking
                Text("Coming Soon")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Body Metrics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WaterIntakeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Track your daily water intake")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()

                Text("Coming Soon")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Water Intake")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProgressPhotosView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Document your progress with photos")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()

                Text("Coming Soon")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Progress Photos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MealPlannerView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Plan your meals for the week")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()

                Text("Coming Soon")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Meal Planner")
        .navigationBarTitleDisplayMode(.inline)
    }
}
