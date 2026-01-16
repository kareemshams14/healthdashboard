# JoeyMed Patient Tools iOS App

Advanced iOS application for joeymed.com patients with comprehensive tools, renewal management, and communication features.

## Features

### 🔐 Authentication
- Secure login with keychain storage
- Token-based authentication
- Biometric authentication support

### 🏥 Patient Tools
- **BMI Calculator**: Calculate and track Body Mass Index
- **Dosage Tracker**: Monitor medication dosage over time
- **Weight Tracker**: Track weight progress with charts
- **Calorie Calculator**: Calculate daily caloric needs (BMR/TDEE)
- **Body Metrics**: Track comprehensive body measurements
- **Water Intake**: Monitor daily hydration
- **Progress Photos**: Document transformation journey
- **Meal Planner**: Plan weekly meals

### 💊 Prescription Management
- View active prescriptions
- Track expiration dates and refills
- Request prescription renewals
- Renewal status tracking
- Payment processing for renewals

### 📅 Appointments
- View upcoming and past appointments
- Book new appointments
- Cancel appointments
- Integrated with GHL calendar
- Support for telehealth, office, and phone appointments

### 💬 Messaging
- Secure communication with providers
- Real-time messaging through GHL
- Conversation history
- Unread message notifications

### 💳 Payments
- Stripe integration for secure payments
- Manage payment methods
- View invoices and payment history
- One-tap payment for renewals

## Architecture

### Core Components

```
JoeyMedPatient/
├── Models/                  # Data models
│   ├── Patient.swift
│   ├── Prescription.swift
│   ├── Appointment.swift
│   └── Message.swift
├── Services/               # Business logic and API integration
│   ├── APIClient.swift
│   ├── AuthenticationManager.swift
│   ├── GHLService.swift
│   └── StripeService.swift
├── Store/                  # State management
│   └── PatientStore.swift
└── Views/                  # UI components
    ├── Auth/
    ├── Dashboard/
    ├── Tools/
    ├── Prescriptions/
    ├── Appointments/
    └── Messages/
```

## Integration

### GoHighLevel (GHL) CRM
The app integrates with GHL for:
- **Calendar**: Appointment scheduling and management
- **Messaging**: Patient-provider communication
- **Contact Management**: Patient data synchronization

### Stripe
Payment processing for:
- Prescription renewals
- Subscription management
- Invoice tracking

## Setup

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Configuration

1. **API Keys**: Update `Config.swift` with your API keys:
   ```swift
   static let ghlAPIKey = "YOUR_GHL_API_KEY"
   static let stripePublishableKey = "YOUR_STRIPE_KEY"
   ```

2. **Backend API**: Configure your backend API URL in `Config.swift`:
   ```swift
   static let apiBaseURL = "https://api.joeymed.com"
   ```

3. **Bundle Identifier**: Update in Xcode project settings

### Installation

1. Clone the repository
2. Open `JoeyMedPatient.xcodeproj` in Xcode
3. Update configuration in `Config.swift`
4. Build and run (⌘ + R)

## Backend Requirements

The app expects the following API endpoints:

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `GET /patient/me` - Get current patient data

### Prescriptions
- `GET /prescriptions` - List prescriptions
- `POST /renewals` - Create renewal request
- `POST /renewals/:id/payment` - Process renewal payment

### Appointments (via GHL)
- Managed through GHL API integration

### Messaging (via GHL)
- Managed through GHL API integration

### Payments (via Stripe)
- `POST /payments/create-intent` - Create payment intent
- `POST /payments/confirm` - Confirm payment
- `GET /payments/methods` - List payment methods
- `POST /payments/methods` - Add payment method

## Security

- **Keychain**: Secure token storage
- **HTTPS**: All API calls use TLS
- **Biometric Auth**: Face ID/Touch ID support
- **PCI Compliance**: Stripe handles all card data

## Color Scheme

- **Primary Blue**: #06b6d4 (Cyan/Sky Blue)
- Used consistently throughout the app for primary actions and branding

## Future Enhancements

- [ ] HealthKit integration for automatic weight/health data sync
- [ ] Push notifications for appointments and messages
- [ ] Apple Pay integration
- [ ] Siri shortcuts for quick actions
- [ ] Widget support for dashboard overview
- [ ] Dark mode optimization
- [ ] iPad support with split views

## Support

For issues or questions:
- Email: support@joeymed.com
- Website: https://joeymed.com/support

## License

Copyright © 2024 JoeyMed. All rights reserved.
