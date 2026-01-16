//
//  CalorieCalculatorView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct CalorieCalculatorView: View {
    @State private var age = ""
    @State private var gender: Patient.Gender = .male
    @State private var heightFeet = ""
    @State private var heightInches = ""
    @State private var weight = ""
    @State private var activityLevel: Patient.ActivityLevel = .moderatelyActive
    @State private var calculatedBMR: Double?
    @State private var calculatedTDEE: Double?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)

                    Text("Calorie Calculator")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Calculate your daily caloric needs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Input Form
                VStack(spacing: 16) {
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Picker("Gender", selection: $gender) {
                        ForEach(Patient.Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)

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

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity Level")
                            .font(.headline)

                        Picker("Activity Level", selection: $activityLevel) {
                            ForEach(Patient.ActivityLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Button(action: calculateCalories) {
                    Text("Calculate")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(!isFormValid)

                // Results
                if let bmr = calculatedBMR, let tdee = calculatedTDEE {
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Basal Metabolic Rate")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("\(Int(bmr)) cal/day")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.orange)

                            Text("Calories burned at rest")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(16)

                        VStack(spacing: 8) {
                            Text("Total Daily Energy Expenditure")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("\(Int(tdee)) cal/day")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.red)

                            Text("Calories needed to maintain weight")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(16)

                        // Weight Goals
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Weight Goals")
                                .font(.headline)

                            CalorieGoalRow(title: "Mild Weight Loss", subtitle: "0.5 lb/week", calories: Int(tdee - 250))
                            CalorieGoalRow(title: "Weight Loss", subtitle: "1 lb/week", calories: Int(tdee - 500))
                            CalorieGoalRow(title: "Extreme Weight Loss", subtitle: "2 lb/week", calories: Int(tdee - 1000))
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
            .padding(.vertical)
        }
        .navigationTitle("Calorie Calculator")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var isFormValid: Bool {
        !age.isEmpty && !heightFeet.isEmpty && !heightInches.isEmpty && !weight.isEmpty
    }

    private func calculateCalories() {
        guard let ageValue = Double(age),
              let feet = Double(heightFeet),
              let inches = Double(heightInches),
              let weightValue = Double(weight) else {
            return
        }

        // Convert to metric
        let heightCm = ((feet * 12) + inches) * 2.54
        let weightKg = weightValue * 0.453592

        // Mifflin-St Jeor Equation
        var bmr: Double

        if gender == .male {
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * ageValue) + 5
        } else {
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * ageValue) - 161
        }

        // Calculate TDEE based on activity level
        let activityMultiplier: Double = {
            switch activityLevel {
            case .sedentary: return 1.2
            case .lightlyActive: return 1.375
            case .moderatelyActive: return 1.55
            case .veryActive: return 1.725
            case .extremelyActive: return 1.9
            }
        }()

        let tdee = bmr * activityMultiplier

        withAnimation {
            calculatedBMR = bmr
            calculatedTDEE = tdee
        }
    }
}

struct CalorieGoalRow: View {
    let title: String
    let subtitle: String
    let calories: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(calories) cal/day")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        CalorieCalculatorView()
    }
}
