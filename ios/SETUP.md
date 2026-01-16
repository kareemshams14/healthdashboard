# JoeyMed iOS App - Setup Guide

This guide will help you set up and configure the JoeyMed Patient Tools iOS app.

## Prerequisites

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- Apple Developer Account (for device testing and App Store deployment)
- GoHighLevel CRM account with API access
- Stripe account with API keys

## Step 1: Project Setup

1. Open Terminal and navigate to the project directory:
   ```bash
   cd /path/to/healthdashboard/ios
   ```

2. Open the project in Xcode:
   ```bash
   open JoeyMedPatient.xcodeproj
   ```

## Step 2: Configure API Keys

### Option A: Using Environment Variables (Development)

Create a `.env` file in the project root:
```bash
GHL_API_KEY=your_ghl_api_key_here
GHL_LOCATION_ID=your_ghl_location_id
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_test_key
```

### Option B: Hardcode in Config.swift (Not Recommended for Production)

Edit `Config.swift`:
```swift
static let ghlAPIKey = "your_ghl_api_key_here"
static let ghlLocationId = "your_ghl_location_id"
static let stripePublishableKey = "pk_test_your_stripe_test_key"
```

**⚠️ Important**: Never commit API keys to version control!

## Step 3: Backend API Configuration

Update the API base URL in `Config.swift`:

```swift
static let apiBaseURL: String = {
    #if DEBUG
    return "https://api-dev.joeymed.com"  // Your development API
    #else
    return "https://api.joeymed.com"      // Your production API
    #endif
}()
```

## Step 4: Configure Bundle Identifier

1. In Xcode, select the project in the navigator
2. Select the target "JoeyMedPatient"
3. Go to "Signing & Capabilities"
4. Update the Bundle Identifier: `com.joeymed.patient` (or your preferred identifier)
5. Select your development team

## Step 5: Set Up GoHighLevel Integration

### Required GHL Permissions
Your GHL API key needs the following scopes:
- `calendars.readonly`
- `calendars.write`
- `contacts.readonly`
- `contacts.write`
- `conversations.readonly`
- `conversations.write`
- `conversations/message.readonly`
- `conversations/message.write`

### Get Your GHL API Key
1. Log in to GoHighLevel
2. Go to Settings → Company Settings → API
3. Create a new API key with required scopes
4. Copy the key and add it to your configuration

### Get Your GHL Location ID
1. In GoHighLevel, go to Settings → Business Profile
2. Copy your Location ID
3. Add it to your configuration

## Step 6: Set Up Stripe Integration

### Development (Test Mode)
1. Log in to Stripe Dashboard
2. Switch to Test mode (toggle in upper right)
3. Go to Developers → API Keys
4. Copy the "Publishable key" (starts with `pk_test_`)
5. Add it to your configuration

### Production (Live Mode)
1. Complete Stripe account activation
2. Switch to Live mode
3. Go to Developers → API Keys
4. Copy the "Publishable key" (starts with `pk_live_`)
5. Update Config.swift for production

**Note**: The app should handle Stripe payment intents through your backend for security.

## Step 7: Backend API Setup

Your backend needs to implement these endpoints:

### Authentication Endpoints
```
POST /auth/login
POST /auth/register
POST /auth/refresh
GET /patient/me
```

### Prescription Endpoints
```
GET /prescriptions
POST /renewals
GET /renewals/:id
POST /renewals/:id/payment
```

### Payment Endpoints (Stripe Proxy)
```
POST /payments/create-intent
POST /payments/confirm
GET /payments/methods
POST /payments/methods
DELETE /payments/methods/:id
PUT /payments/methods/default
GET /payments/invoices
```

## Step 8: Configure App Capabilities

In Xcode, go to Signing & Capabilities and add:

1. **Keychain Sharing** (for secure token storage)
   - Add Keychain Group: `$(AppIdentifierPrefix)com.joeymed.patient`

2. **Push Notifications** (optional, for future use)

3. **HealthKit** (optional, for future health data integration)

## Step 9: Build and Run

1. Select a simulator or connected device
2. Press ⌘ + R to build and run
3. The app should launch with the login screen

## Step 10: Testing

### Test Credentials
Create test accounts in your backend for testing:
- Email: `test@joeymed.com`
- Password: `Test123!`

### Test Payment Cards (Stripe Test Mode)
- Success: `4242 4242 4242 4242`
- Requires Authentication: `4000 0025 0000 3155`
- Declined: `4000 0000 0000 0002`
- Use any future expiration date and any CVC

## Troubleshooting

### Build Errors

**Issue**: Cannot find symbol 'Chart'
**Solution**: Ensure iOS Deployment Target is set to iOS 16.0+ (Charts requires iOS 16)

**Issue**: Keychain access denied
**Solution**: Check that Keychain Sharing capability is properly configured

### Runtime Errors

**Issue**: API calls fail with 401 Unauthorized
**Solution**: Check that your API token is valid and properly stored in Keychain

**Issue**: GHL integration fails
**Solution**:
1. Verify GHL API key is correct
2. Check that all required permissions are enabled
3. Verify Location ID is correct

**Issue**: Stripe payment fails
**Solution**:
1. Ensure Stripe publishable key is correct
2. Verify backend is creating payment intents properly
3. Check Stripe webhook is configured

## Production Checklist

Before submitting to App Store:

- [ ] Update bundle identifier for production
- [ ] Configure production API URLs
- [ ] Use production Stripe keys
- [ ] Use production GHL credentials
- [ ] Enable proper error logging
- [ ] Test all payment flows
- [ ] Test on multiple devices and iOS versions
- [ ] Review and update Privacy Policy
- [ ] Configure App Store Connect
- [ ] Prepare screenshots and metadata
- [ ] Enable TestFlight for beta testing

## Support

For technical support:
- Email: dev@joeymed.com
- Documentation: https://docs.joeymed.com

## Security Notes

1. **Never** commit API keys or secrets to git
2. Use environment variables or secure configuration management
3. Implement certificate pinning for production
4. Enable App Transport Security (ATS)
5. Regular security audits recommended
6. Follow HIPAA compliance guidelines for health data
