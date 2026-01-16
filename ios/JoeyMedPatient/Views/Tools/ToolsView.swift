//
//  ToolsView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct ToolsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Patient Tools")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ToolCard(
                            title: "BMI Calculator",
                            icon: "figure.stand",
                            color: .blue,
                            destination: AnyView(BMICalculatorView())
                        )

                        ToolCard(
                            title: "Dosage Tracker",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .green,
                            destination: AnyView(DosageTrackerView())
                        )

                        ToolCard(
                            title: "Weight Tracker",
                            icon: "scalemass.fill",
                            color: .orange,
                            destination: AnyView(WeightTrackerView())
                        )

                        ToolCard(
                            title: "Body Metrics",
                            icon: "ruler.fill",
                            color: .purple,
                            destination: AnyView(BodyMetricsView())
                        )

                        ToolCard(
                            title: "Calorie Calculator",
                            icon: "flame.fill",
                            color: .red,
                            destination: AnyView(CalorieCalculatorView())
                        )

                        ToolCard(
                            title: "Water Intake",
                            icon: "drop.fill",
                            color: .cyan,
                            destination: AnyView(WaterIntakeView())
                        )

                        ToolCard(
                            title: "Progress Photos",
                            icon: "camera.fill",
                            color: .indigo,
                            destination: AnyView(ProgressPhotosView())
                        )

                        ToolCard(
                            title: "Meal Planner",
                            icon: "fork.knife",
                            color: .mint,
                            destination: AnyView(MealPlannerView())
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ToolCard: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
}

#Preview {
    ToolsView()
}
