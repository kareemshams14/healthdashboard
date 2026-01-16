//
//  MainTabView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var patientStore: PatientStore
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ToolsView()
                .tabItem {
                    Label("Tools", systemImage: "function")
                }
                .tag(1)

            PrescriptionsView()
                .tabItem {
                    Label("Renewals", systemImage: "pills.fill")
                }
                .tag(2)

            AppointmentsView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(3)

            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .tag(4)
        }
        .accentColor(Color("PrimaryBlue"))
        .task {
            await patientStore.loadAllData()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(PatientStore.shared)
        .environmentObject(AuthenticationManager.shared)
}
