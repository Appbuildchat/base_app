# Stripe Payment Integration Setup Guide

This guide will help you set up the Stripe payment system that has been integrated into your Flutter app.

## Prerequisites

1. **Stripe Account**: Sign up at [stripe.com](https://stripe.com) if you don't have an account
2. **Flutter Environment**: Ensure Flutter is installed and working
3. **Firebase Project**: Your Firebase project should be set up (already configured)

## Step 1: Stripe Dashboard Setup

### 1.1 Get Your API Keys
1. Log into your [Stripe Dashboard](https://dashboard.stripe.com)
2. Go to **Developers** → **API keys**
3. Copy your **Publishable key** (starts with `pk_test_` for test mode)
4. Copy your **Secret key** (starts with `sk_test_` for test mode)

### 1.2 Configure Webhooks (Optional for basic functionality)
1. Go to **Developers** → **Webhooks**
2. Click **Add endpoint**
3. Use your Firebase Functions URL: `https://YOUR_PROJECT_ID.cloudfunctions.net/stripeWebhook`
4. Select events: `payment_intent.succeeded`, `payment_intent.payment_failed`

## Step 2: Configure Your Flutter App

### 2.1 Update Stripe Publishable Key
Edit `/lib/domain/payment/presentation/screens/payment_test_screen.dart`:

```dart
// Line ~47, replace with your actual publishable key
Stripe.publishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY_HERE';
```

### 2.2 Android Configuration
Add to `/android/app/build.gradle` (already configured):
```gradle
minSdk = 23  // Required for Stripe
```

### 2.3 iOS Configuration
Add to `/ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>stripe.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSTemporaryExceptionMinimumTLSVersion</key>
            <string>1.0</string>
        </dict>
    </dict>
</dict>
```

## Step 3: Configure Cloud Functions

### 3.1 Set Environment Variables
In your Firebase project, set the Stripe secret key:

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Set the environment variable
firebase functions:config:set stripe.secret_key="sk_test_YOUR_SECRET_KEY_HERE"

# Deploy functions to apply the config
firebase deploy --only functions
```

### 3.2 Install Dependencies
```bash
cd functions
npm install
```

### 3.3 Deploy Cloud Functions
```bash
cd functions
npm run deploy
```

## Step 4: Test the Integration

### 4.1 Run the App
```bash
flutter pub get
flutter run
```

### 4.2 Navigate to Payment Test Screen
- Use the router to navigate to `/payment/test`
- Or add a button in your app to navigate there:
```dart
ElevatedButton(
  onPressed: () => context.go('/payment/test'),
  child: Text('Test Payments'),
)
```

### 4.3 Test Cards
Use these test cards in the payment form:

| Card Number | Description |
|-------------|-------------|
| 4242 4242 4242 4242 | Successful payment |
| 4000 0000 0000 0002 | Card declined |
| 4000 0000 0000 9995 | Insufficient funds |
| 4000 0000 0000 9987 | Lost card |
| 4000 0000 0000 9979 | Stolen card |

**Expiry**: Any future date  
**CVC**: Any 3 digits  
**ZIP**: Any 5 digits (US) or postal code

## Step 5: Available Features

### Payment Test Screen (`/payment/test`)
- ✅ Product selection
- ✅ Payment intent creation
- ✅ Stripe payment sheet integration
- ✅ Payment processing
- ✅ Payment cancellation
- ✅ Success/failure handling
- ✅ Real-time status updates

### Payment History Screen (`/payment/history`)
- ✅ View all payments
- ✅ Filter by payment status
- ✅ Payment details display
- ✅ Receipt viewing (when available)
- ✅ Retry failed payments

### Business Logic Functions
- ✅ `CreatePaymentIntent.create()` - Server-side payment intent creation
- ✅ `ProcessPayment.withPaymentSheet()` - Handle payment processing
- ✅ `CancelPayment.cancel()` - Cancel payment intents
- ✅ `FetchPaymentHistory.forUser()` - Get user payment history
- ✅ `VerifyPayment.verifyPaymentIntent()` - Verify payment status
- ✅ `SavePaymentRecord.save()` - Store payment records in Firestore

## Step 6: Production Setup

### 6.1 Switch to Live Keys
1. Get your live API keys from Stripe Dashboard
2. Update the publishable key in your Flutter app
3. Update the secret key in Firebase Functions config:
```bash
firebase functions:config:set stripe.secret_key="sk_live_YOUR_LIVE_SECRET_KEY"
firebase deploy --only functions
```

### 6.2 Security Considerations
- ✅ Secret key is securely stored in Cloud Functions
- ✅ All payment operations are authenticated
- ✅ Payment intents are created server-side
- ✅ Client never handles sensitive data
- ✅ Error handling follows security best practices

### 6.3 Firestore Security Rules
Add these rules to secure payment data:

```javascript
// Add to your firestore.rules
match /payments/{paymentId} {
  allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
}
```

## Step 7: Troubleshooting

### Common Issues

1. **"Stripe not initialized"**
   - Ensure you've set the publishable key correctly
   - Check that `Stripe.publishableKey` is set before using Stripe

2. **"Payment intent creation failed"**
   - Verify your secret key is correctly set in Firebase Functions
   - Check Firebase Functions logs: `firebase functions:log`

3. **"Authentication required"**
   - Ensure user is signed in before making payments
   - Check Firebase Auth configuration

4. **"Card declined"**
   - Use test card numbers for development
   - Check Stripe Dashboard for payment details

### Debugging Tips

1. **Check Firebase Functions Logs**
```bash
firebase functions:log --only functions
```

2. **Check Flutter Logs**
```bash
flutter logs
```

3. **Check Stripe Dashboard**
- Go to **Payments** to see all transactions
- Go to **Logs** to see API requests

## Step 8: Customization

### Add Custom Products
Edit the test products in `payment_test_screen.dart`:

```dart
final List<ProductEntity> _testProducts = [
  ProductEntity(
    productId: 'your_product_id',
    name: 'Your Product Name',
    description: 'Product description',
    price: 29.99, // Price in dollars
    currency: 'usd',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  // Add more products...
];
```

### Customize UI
- Modify widgets in `/lib/domain/payment/presentation/widgets/`
- Update themes in `/lib/core/themes/`
- Add custom payment flows by following the existing patterns

## Support

For issues related to:
- **Stripe Integration**: Check [Stripe Documentation](https://stripe.com/docs)
- **Flutter Stripe Plugin**: See [flutter_stripe](https://pub.dev/packages/flutter_stripe)
- **Firebase Functions**: See [Firebase Documentation](https://firebase.google.com/docs/functions)

## Security Notice

🔒 **Important**: 
- Never commit your secret keys to version control
- Always use environment variables for sensitive data
- Test thoroughly before going live
- Monitor your Stripe Dashboard regularly