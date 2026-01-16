//
//  BMICalculatorView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct BMICalculatorView: View {
    @State private var heightFeet = ""
    @State private var heightInches = ""
    @State private var weight = ""
    @State private var bmi: Double?
    @State private var category: BMICategory = .normal

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "figure.stand")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("BMI Calculator")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Calculate your Body Mass Index")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Input Fields
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height")
                            .font(.headline)

                        HStack(spacing: 12) {
                            HStack {
                                TextField("Feet", text: $heightFeet)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                Text("ft")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                            HStack {
                                TextField("Inches", text: $heightInches)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                Text("in")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight")
                            .font(.headline)

                        HStack {
                            TextField("Weight", text: $weight)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                            Text("lbs")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                // Calculate Button
                Button(action: calculateBMI) {
                    Text("Calculate BMI")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(!isInputValid)

                // Results
                if let bmi = bmi {
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Your BMI")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text(String(format: "%.1f", bmi))
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(category.color)

                            Text(category.rawValue)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(category.color)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(category.color.opacity(0.1))
                        .cornerRadius(16)

                        // BMI Scale
                        VStack(alignment: .leading, spacing: 12) {
                            Text("BMI Categories")
                                .font(.headline)

                            BMICategoryRow(category: .underweight, isActive: category == .underweight)
                            BMICategoryRow(category: .normal, isActive: category == .normal)
                            BMICategoryRow(category: .overweight, isActive: category == .overweight)
                            BMICategoryRow(category: .obese, isActive: category == .obese)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()
            }
        }
        .navigationTitle("BMI Calculator")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var isInputValid: Bool {
        guard let feet = Double(heightFeet),
              let inches = Double(heightInches),
              let weightValue = Double(weight) else {
            return false
        }

        return feet > 0 && inches >= 0 && weightValue > 0
    }

    private func calculateBMI() {
        guard let feet = Double(heightFeet),
              let inches = Double(heightInches),
              let weightValue = Double(weight) else {
            return
        }

        // Convert height to inches
        let totalInches = (feet * 12) + inches

        // BMI = (weight in pounds × 703) / (height in inches²)
        let calculatedBMI = (weightValue * 703) / (totalInches * totalInches)

        withAnimation {
            bmi = calculatedBMI

            // Determine category
            switch calculatedBMI {
            case ..<18.5:
                category = .underweight
            case 18.5..<25:
                category = .normal
            case 25..<30:
                category = .overweight
            default:
                category = .obese
            }
        }
    }
}

struct BMICategoryRow: View {
    let category: BMICategory
    let isActive: Bool

    var body: some View {
        HStack {
            Circle()
                .fill(category.color)
                .frame(width: 12, height: 12)

            Text(category.rawValue)
                .font(isActive ? .headline : .subheadline)
                .foregroundColor(isActive ? .primary : .secondary)

            Spacer()

            Text(category.range)
                .font(isActive ? .headline : .subheadline)
                .foregroundColor(isActive ? category.color : .secondary)
        }
        .padding(.vertical, 4)
    }
}

enum BMICategory: String {
    case underweight = "Underweight"
    case normal = "Normal"
    case overweight = "Overweight"
    case obese = "Obese"

    var color: Color {
        switch self {
        case .underweight:
            return .cyan
        case .normal:
            return .green
        case .overweight:
            return .orange
        case .obese:
            return .red
        }
    }

    var range: String {
        switch self {
        case .underweight:
            return "< 18.5"
        case .normal:
            return "18.5 - 24.9"
        case .overweight:
            return "25 - 29.9"
        case .obese:
            return "≥ 30"
        }
    }
}

#Preview {
    NavigationView {
        BMICalculatorView()
    }
}
