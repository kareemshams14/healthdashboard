//
//  WeightTrackerView.swift
//  JoeyMed Patient Tools
//

import SwiftUI
import Charts

struct WeightTrackerView: View {
    @State private var weightHistory: [WeightEntry] = []
    @State private var showAddEntry = false
    @State private var goalWeight: Double = 150.0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress Summary
                if !weightHistory.isEmpty, let first = weightHistory.first, let last = weightHistory.last {
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            VStack {
                                Text("Current")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(last.weight, specifier: "%.1f") lbs")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }

                            Divider()
                                .frame(height: 40)

                            VStack {
                                Text("Goal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(goalWeight, specifier: "%.1f") lbs")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }

                            Divider()
                                .frame(height: 40)

                            VStack {
                                Text("Progress")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                let progress = first.weight - last.weight
                                Text("\(progress, specifier: "%.1f") lbs")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(progress > 0 ? .green : .red)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                // Chart
                if !weightHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weight Progress")
                            .font(.headline)

                        Chart {
                            ForEach(weightHistory) { entry in
                                LineMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Weight", entry.weight)
                                )
                                .foregroundStyle(.orange)
                                .symbol(.circle)

                                PointMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Weight", entry.weight)
                                )
                                .foregroundStyle(.orange)
                            }

                            // Goal line
                            RuleMark(y: .value("Goal", goalWeight))
                                .foregroundStyle(.green.opacity(0.5))
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        }
                        .frame(height: 250)
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisValueLabel {
                                    if let weight = value.as(Double.self) {
                                        Text("\(weight, specifier: "%.0f") lbs")
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "scalemass.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No weight history yet")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("Start tracking your weight progress")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 60)
                }

                // History List
                if !weightHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("History")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(weightHistory.reversed()) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(entry.weight, specifier: "%.1f") lbs")
                                        .font(.headline)

                                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if let notes = entry.notes {
                                    Text(notes)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Weight Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddEntry = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAddEntry) {
            AddWeightEntryView(weightHistory: $weightHistory)
        }
        .onAppear {
            loadSampleData()
        }
    }

    private func loadSampleData() {
        if weightHistory.isEmpty {
            weightHistory = [
                WeightEntry(weight: 180, date: Date().addingTimeInterval(-28 * 24 * 3600)),
                WeightEntry(weight: 178, date: Date().addingTimeInterval(-21 * 24 * 3600)),
                WeightEntry(weight: 176, date: Date().addingTimeInterval(-14 * 24 * 3600)),
                WeightEntry(weight: 174, date: Date().addingTimeInterval(-7 * 24 * 3600)),
                WeightEntry(weight: 172, date: Date())
            ]
        }
    }
}

struct AddWeightEntryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var weightHistory: [WeightEntry]
    @State private var weight = ""
    @State private var selectedDate = Date()
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Weight Information") {
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        Text("lbs")
                            .foregroundColor(.secondary)
                    }

                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }

                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Weight Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(weight.isEmpty)
                }
            }
        }
    }

    private func saveEntry() {
        guard let weightValue = Double(weight) else { return }

        let entry = WeightEntry(
            weight: weightValue,
            date: selectedDate,
            notes: notes.isEmpty ? nil : notes
        )

        weightHistory.append(entry)
        weightHistory.sort { $0.date < $1.date }

        dismiss()
    }
}

struct WeightEntry: Identifiable {
    let id = UUID()
    let weight: Double
    let date: Date
    let notes: String?
}

#Preview {
    NavigationView {
        WeightTrackerView()
    }
}
