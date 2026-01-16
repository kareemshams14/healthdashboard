//
//  DosageTrackerView.swift
//  JoeyMed Patient Tools
//

import SwiftUI
import Charts

struct DosageTrackerView: View {
    @State private var dosageHistory: [DosageEntry] = []
    @State private var showAddEntry = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Chart
                if !dosageHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Dosage History")
                            .font(.headline)

                        Chart(dosageHistory) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Dosage", entry.dosage)
                            )
                            .foregroundStyle(.blue)
                            .symbol(.circle)

                            PointMark(
                                x: .value("Date", entry.date),
                                y: .value("Dosage", entry.dosage)
                            )
                            .foregroundStyle(.blue)
                        }
                        .frame(height: 250)
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisValueLabel {
                                    if let dosage = value.as(Double.self) {
                                        Text("\(dosage, specifier: "%.2f") mg")
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Current Dosage Card
                    if let latestEntry = dosageHistory.last {
                        VStack(spacing: 8) {
                            Text("Current Dosage")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("\(latestEntry.dosage, specifier: "%.2f") mg")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.blue)

                            Text("Last updated: \(latestEntry.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No dosage history yet")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("Start tracking your medication dosage")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 60)
                }

                // History List
                if !dosageHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("History")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(dosageHistory.reversed()) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(entry.dosage, specifier: "%.2f") mg")
                                        .font(.headline)

                                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
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
        .navigationTitle("Dosage Tracker")
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
            AddDosageEntryView(dosageHistory: $dosageHistory)
        }
        .onAppear {
            loadSampleData()
        }
    }

    private func loadSampleData() {
        if dosageHistory.isEmpty {
            // Sample data
            dosageHistory = [
                DosageEntry(dosage: 0.25, date: Date().addingTimeInterval(-21 * 24 * 3600)),
                DosageEntry(dosage: 0.25, date: Date().addingTimeInterval(-14 * 24 * 3600)),
                DosageEntry(dosage: 0.50, date: Date().addingTimeInterval(-7 * 24 * 3600)),
                DosageEntry(dosage: 0.50, date: Date())
            ]
        }
    }
}

struct AddDosageEntryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var dosageHistory: [DosageEntry]
    @State private var dosage = ""
    @State private var selectedDate = Date()
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Dosage Information") {
                    HStack {
                        TextField("Dosage", text: $dosage)
                            .keyboardType(.decimalPad)
                        Text("mg")
                            .foregroundColor(.secondary)
                    }

                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Dosage Entry")
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
                    .disabled(dosage.isEmpty)
                }
            }
        }
    }

    private func saveEntry() {
        guard let dosageValue = Double(dosage) else { return }

        let entry = DosageEntry(
            dosage: dosageValue,
            date: selectedDate,
            notes: notes.isEmpty ? nil : notes
        )

        dosageHistory.append(entry)
        dosageHistory.sort { $0.date < $1.date }

        dismiss()
    }
}

struct DosageEntry: Identifiable {
    let id = UUID()
    let dosage: Double
    let date: Date
    let notes: String?
}

#Preview {
    NavigationView {
        DosageTrackerView()
    }
}
