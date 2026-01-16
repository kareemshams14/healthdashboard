//
//  MessagesView.swift
//  JoeyMed Patient Tools
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var patientStore: PatientStore
    @State private var showNewMessage = false

    var body: some View {
        NavigationView {
            Group {
                if patientStore.conversations.isEmpty {
                    emptyStateView
                } else {
                    conversationsList
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewMessage = true }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showNewMessage) {
                NewMessageView()
            }
            .refreshable {
                await patientStore.loadConversations()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding(.top, 60)

            Text("No Messages")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start a conversation with your provider")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: { showNewMessage = true }) {
                Text("New Message")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    private var conversationsList: some View {
        List {
            ForEach(patientStore.conversations) { conversation in
                NavigationLink(destination: ConversationView(conversation: conversation)) {
                    ConversationRow(conversation: conversation)
                }
            }
        }
        .listStyle(.plain)
    }
}

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: "person.fill")
                    .foregroundColor(.purple)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.subject)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Spacer()

                    Text(conversation.updatedAt.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            // Unread Badge
            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 4)
    }
}

struct ConversationView: View {
    @EnvironmentObject var patientStore: PatientStore
    let conversation: Conversation

    @State private var messages: [Message] = []
    @State private var newMessageText = ""
    @State private var isSending = false

    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input Bar
            HStack(spacing: 12) {
                TextField("Type a message...", text: $newMessageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .lineLimit(1...5)

                Button(action: sendMessage) {
                    if isSending {
                        ProgressView()
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(newMessageText.isEmpty ? .gray : .blue)
                    }
                }
                .disabled(newMessageText.isEmpty || isSending)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle(conversation.subject)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadMessages()
        }
    }

    private func loadMessages() async {
        do {
            let fetchedMessages = try await GHLService.shared.fetchMessages(conversationId: conversation.id)

            await MainActor.run {
                messages = fetchedMessages
            }
        } catch {
            print("Failed to load messages: \(error)")
        }
    }

    private func sendMessage() {
        guard !newMessageText.isEmpty else { return }

        let messageContent = newMessageText
        newMessageText = ""
        isSending = true

        Task {
            do {
                try await patientStore.sendMessage(
                    conversationId: conversation.id,
                    message: messageContent
                )

                // Reload messages
                await loadMessages()

                await MainActor.run {
                    isSending = false
                }
            } catch {
                print("Failed to send message: \(error)")

                await MainActor.run {
                    newMessageText = messageContent
                    isSending = false
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.senderType == .patient {
                Spacer()
            }

            VStack(alignment: message.senderType == .patient ? .trailing : .leading, spacing: 4) {
                if message.senderType != .patient {
                    Text(message.senderName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }

                Text(message.content)
                    .font(.subheadline)
                    .padding(12)
                    .background(message.senderType == .patient ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.senderType == .patient ? .white : .primary)
                    .cornerRadius(16)

                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 280, alignment: message.senderType == .patient ? .trailing : .leading)

            if message.senderType != .patient {
                Spacer()
            }
        }
    }
}

struct NewMessageView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var patientStore: PatientStore
    @State private var subject = ""
    @State private var messageText = ""
    @State private var isSending = false

    var body: some View {
        NavigationView {
            Form {
                Section("Subject") {
                    TextField("Subject", text: $subject)
                }

                Section("Message") {
                    TextEditor(text: $messageText)
                        .frame(height: 200)
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        sendMessage()
                    }
                    .disabled(subject.isEmpty || messageText.isEmpty || isSending)
                }
            }
        }
    }

    private func sendMessage() {
        isSending = true

        Task {
            do {
                _ = try await patientStore.startNewConversation(message: messageText)

                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Failed to send: \(error)")
                isSending = false
            }
        }
    }
}

#Preview {
    MessagesView()
        .environmentObject(PatientStore.shared)
}
