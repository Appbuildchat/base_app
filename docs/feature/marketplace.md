# Marketplace Feature Documentation

## Overview
The marketplace feature enables users to create and browse item listings within the app. This is a comprehensive e-commerce system that supports product browsing, shopping cart functionality, order processing, and payment integration. The system accommodates both buyers and sellers with tools for product management, order tracking, and secure transactions.

## Core Features (Essential - Always Required)

### Must-Have Screens
1. **Product Catalog Screen** - Browse available products with search and filtering
2. **Product Detail Screen** - View detailed product information with reviews
3. **Shopping Cart Screen** - Manage cart items and quantities
4. **Checkout Screen** - Complete purchase with payment processing
5. **Order Confirmation Screen** - Order completion confirmation after payment (for offline products)
6. **Order History Screen** - View past orders and tracking information
7. **Seller Dashboard Screen** - Manage product listings and orders (for sellers)

### Must-Have Features
- **Basic Product Management**
  - Create, read, update, delete product listings
  - Category-based organization
  - Basic media upload (product images)
  - List/grid view toggle
  - Search and filter functionality

- **Shopping Cart & Checkout**
  - Add/remove products from cart
  - Quantity management (real-time stock verification for offline products)
  - Automatic cart quantity adjustment (auto-adjust to max stock when insufficient + warning messages)
  - Cart persistence across sessions
  - Secure payment processing using existing `/lib/domain/payment/` system
  - Order confirmation and tracking

- **Offline Product Management (Physical Products)**
  - Shipping address management (basic 1 address)
  - Product quantity selection and total price calculation
  - Real-time stock verification and management
  - Final stock verification at checkout

- **Order Management**
  - Order creation from cart checkout
  - Order status tracking (paid, shipped, delivered, cancelled)
  - Order status can only be changed by sellers
  - Order modification/cancellation functionality (available until shipping starts, cancellation reason required)
  - Order history and detailed information viewing
  - Order confirmation screen provides marketplace navigation, order modification/cancellation buttons

- **App Store Compliance** (Mandatory for store approval)
  - Report inappropriate products and reviews
  - Block users functionality
  - Content moderation tools

### Core Domain Structure
Following the project's architecture rules:
```
lib/domain/marketplace/
├── entities/
│   ├── product_entity.dart         # Extended from payment domain
│   ├── cart_entity.dart            # Shopping cart data
│   ├── cart_item_entity.dart       # Individual cart items
│   ├── order_entity.dart           # Order data model (includes shipping address)
│   ├── order_item_entity.dart      # Individual order items
│   ├── review_entity.dart          # Product reviews
│   ├── report_entity.dart          # For moderation
│   └── shipping_address_entity.dart # Shipping address (included in OrderEntity)
├── functions/
│   ├── fetch_products.dart         # Get product listings
│   ├── search_products.dart        # Product search
│   ├── filter_products.dart        # Product filtering
│   ├── add_to_cart.dart            # Cart management
│   ├── update_cart_item.dart       # Modify cart items
│   ├── check_stock_availability.dart # Real-time stock verification
│   ├── validate_cart_stock.dart    # Final stock verification at checkout
│   ├── process_checkout.dart       # Uses payment domain
│   ├── create_order.dart           # Order creation
│   ├── track_order.dart            # Order tracking
│   ├── update_order_status.dart    # Order status change (for sellers)
│   ├── cancel_order.dart           # Order cancellation (for customers)
│   ├── modify_order.dart           # Order modification (before shipping)
│   ├── create_review.dart          # Product reviews
│   ├── create_product_listing.dart # For sellers
│   ├── update_product_listing.dart # Seller product management
│   └── report_product.dart         # Required for App Store
└── presentation/
    ├── screens/
    │   ├── product_catalog_screen.dart
    │   ├── product_detail_screen.dart
    │   ├── cart_screen.dart
    │   ├── checkout_screen.dart
    │   ├── order_confirmation_screen.dart # Order confirmation screen
    │   ├── order_history_screen.dart
    │   ├── order_detail_screen.dart
    │   └── seller_dashboard_screen.dart
    └── widgets/
        ├── product_card.dart
        ├── cart_item_widget.dart
        ├── checkout_form.dart
        ├── order_status_widget.dart
        ├── stock_warning_widget.dart     # Stock warnings
        ├── shipping_address_widget.dart  # Shipping address
        └── review_widget.dart
```

### Basic Entity Structure
```dart
// Extended product entity for marketplace
class MarketplaceProductEntity extends ProductEntity {
  final String sellerId;
  final String category;
  final List<String> imageUrls;
  final int stockQuantity;
  final double averageRating;
  final int reviewCount;
  final bool isActive;
  final bool isReported;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Additional fields added based on customization needs
}

// Shopping cart entity
class CartEntity {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// Shipping address entity (for offline products)
class ShippingAddressEntity {
  final String postalCode;        # Postal code
  final String city;              # City/Province
  final String district;          # District/County
  final String detailAddress;     # Detailed address
  final String recipientName;     # Recipient name
  final String phoneNumber;       # Phone number
}

// Order entity (includes shipping address)
class OrderEntity {
  final String id;
  final String userId;
  final String sellerId;
  final List<OrderItemEntity> items;
  final double total;
  final OrderStatus status;
  final ShippingAddressEntity shippingAddress; // Shipping address information
  final String paymentIntentId; // Links to payment domain
  final String? cancellationReason; // Cancellation reason
  final DateTime createdAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
}

// Order status enum (for offline products)
enum OrderStatus {
  paid,         // Payment completed
  shipped,      // Shipping started
  delivered,    // Delivered
  cancelled,    // Order cancelled
}
```

## Integration with Payment Domain
**CRITICAL**: The marketplace MUST use the existing `/lib/domain/payment/` system for all payment processing:

- **Payment Processing**: Use `CreatePaymentIntent.create()` and `ProcessPayment.withPaymentSheet()`
- **Payment Records**: Leverage `PaymentEntity` for transaction storage
- **Product Data**: Extend existing `ProductEntity` from payment domain
- **Payment History**: Use `FetchPaymentHistory.forUser()` for order payment records

### Payment Integration Example
```dart
// Process cart checkout using existing payment system
import '../../domain/payment/functions/create_payment_intent.dart';
import '../../domain/payment/functions/process_payment.dart';

final paymentIntent = await CreatePaymentIntent.create(
  amount: cartTotal.amountInCents,
  currency: 'usd',
  userId: currentUser.uid,
  productId: 'cart_checkout_${cartId}'
);

final paymentResult = await ProcessPayment.withPaymentSheet(
  paymentIntent: paymentIntent.data!,
  userId: currentUser.uid,
  productId: 'cart_checkout_${cartId}'
);
```

## Customizable Features (App-Specific - Choose Based on Use Case)

### Offline Products (Physical Products) Customizations

#### Shipping & Logistics Management
- **Advanced Address Management**
  - Multiple shipping address storage and management
  - Address verification and auto-completion features
  - Default shipping address settings

- **Shipping System**
  - Shipping cost calculation system (fixed/weight/distance-based)
  - Free shipping condition settings
  - Multiple shipping methods (standard/express/same-day delivery)
  - Shipping tracking system (tracking numbers, real-time GPS tracking)
  - Pickup location designation
  - International shipping
  - Shipping notification system
  - Proof of delivery

#### Physical Inventory Management
- **Stock Quantity Management**
  - Product-specific maximum order quantity limits
  - Stock alert system

#### Order & Customer Service
- **Order Processing**
  - Automatic order status notifications (email/push)
  - Seller approval-based order cancellation
  - Extended order modification timeframe
  - Partial cancellation/refund functionality

- **Return/Exchange System**
  - Return/exchange request system
  - Return reason management
  - Refund processing workflow
  - Return/refund processing

- **Customer Service**
  - Receipt download/email sending
  - Customer-seller communication tools

### Digital Products Customizations
- **File Management**
  - Support for various file formats
  - Version history and compatibility management
  - Enhanced preview system
  - Download count limitations

- **License Management**
  - Extended license type variations
  - Detailed usage permission settings
  - License period management

### Common Customizations (All Product Types)

#### System & Operations Management
- **Real-time Stock Tracking**
  - Real-time stock quantity monitoring
  - Low stock alert system
  - Stock analysis and forecasting

- **Advanced Pricing System**
  - Discount codes and promotions
  - Bulk pricing tiers
  - Dynamic pricing algorithms
  - Subscription-based products

#### Search & Discovery Customizations
- **Enhanced Search**
  - AI-powered search suggestions
  - Visual search with image recognition
  - Voice search capabilities
  - Search analytics and trending

- **Recommendation System**
  - Personalized product recommendations
  - Recently viewed items
  - Frequently bought together
  - Cross-selling and upselling

#### Social & Trust Customizations
- **Review & Rating System**
  - Photo/video reviews
  - Verified purchase reviews
  - Review helpfulness voting
  - Seller response to reviews

- **Social Commerce Features**
  - Wishlist sharing
  - Social media integration
  - Influencer partnerships
  - Live shopping events

#### Business Intelligence Customizations
- **Analytics & Reporting**
  - Sales performance dashboards
  - Customer behavior analytics
  - Inventory turnover reports
  - Profit margin analysis

- **Seller Tools**
  - Multi-channel inventory sync
  - Automated pricing tools
  - Marketing campaign management
  - Customer communication tools

## UI/UX Guidelines

### Design System Integration
- **Colors**: Use AppColors and AppHSLColors throughout
- **Spacing**: Apply AppSpacing tokens for consistent layout
- **Components**: Leverage AppCard, AppButtons, and existing widgets
- **Typography**: Follow AppTypography for text hierarchy

### Basic Screen Layouts
Following the UI guidelines from `/docs/ui_guideline.md`:

#### Core Layout Pattern
```
┌─────────────────────┐
│      Header         │ (Search, Cart, Filter)
├─────────────────────┤
│   [Categories]      │ (Horizontal scrollable)
├─────────────────────┤
│                     │
│    Product Grid     │ (Main content area)
│                     │
│                     │
└─────────────────────┘
```

#### Product Card Structure
```
┌─────────────────────┐
│   Product Image     │ (Main visual)
├─────────────────────┤
│ Title               │
│ ★★★★☆ (24)         │ (Rating & review count)
│ $29.99              │ (Price)
│ Stock: 15 units     │ (Stock info - offline products)
│     [Add to Cart]   │ (Action button)
└─────────────────────┘
```

#### Shopping Cart Layout (for offline products)
```
┌─────────────────────┐
│   Cart Items        │
│   ┌─────────────┐   │
│   │ Item + Qty  │   │ (Repeating items)
│   │ ⚠️Low Stock │   │ (Stock warning message)
│   └─────────────┘   │
├─────────────────────┤
│   Shipping Address  │
│   [Enter/Edit Addr] │
├─────────────────────┤
│   Order Summary     │
│   Subtotal: $X      │
│   Tax: $Y           │
│   Shipping: $Z      │
│   Total: $Total     │
├─────────────────────┤
│   [Checkout]        │
└─────────────────────┘
```

#### Order Confirmation Screen Layout (for offline products)
```
┌─────────────────────┐
│  ✅Order Completed  │
├─────────────────────┤
│   Order #: #12345   │
│   Order Date: Date  │
├─────────────────────┤
│   Purchased Items   │
│   - Product A x 2   │
│   - Product B x 1   │
├─────────────────────┤
│   Total: $Total     │
├─────────────────────┤
│   Shipping Address  │
│   John Doe          │
│   123 Main St...    │
├─────────────────────┤
│  [Back to Market]   │
│  [Modify Order]     │
│  [Cancel Order]     │
└─────────────────────┘
```

## Implementation Strategy

### Step 1: Core Shopping Experience
1. Create basic product catalog with search and filtering
2. Implement shopping cart functionality (including real-time stock verification)
3. Build checkout process using existing payment system
4. Add shipping address management functionality
5. Add required reporting/blocking features

### Step 2: Order Management
1. Implement order creation from successful checkout (including shipping address)
2. Build order status tracking and update system
3. Create order confirmation screen and order history screens
4. Implement order modification/cancellation functionality

### Step 3: Seller Tools
1. Add product listing creation and management (including inventory management)
2. Implement seller dashboard with order processing
3. Add order status change tools
4. Create sales analytics and reporting

### Step 4: Enhanced Features
1. Add product review and rating system
2. Implement advanced search and recommendations
3. Add wishlist and favorites functionality
4. Include promotional and discount features

### Required Integrations (All Apps)
- **Authentication System**: User management and access control
- **Payment System**: MUST use existing `/lib/domain/payment/` for all transactions
- **File Upload System**: Use existing `/lib/core/image_picker/` for product images
- **Report/Block System**: For App Store compliance

### Optional Integrations (Choose Based on Need)
- **Location Services**: Shipping address and delivery tracking
- **Push Notifications**: Order updates and promotional messages
- **Analytics**: Purchase behavior and sales tracking
- **Search System**: Advanced product discovery

## Customization Examples

### E-commerce Marketplace (Offline Products)
```dart
class EcommerceProductEntity extends MarketplaceProductEntity {
  final String brand;
  final String condition; // new, used, refurbished
  final List<String> colors;
  final List<String> sizes;
  final double weight;
  final String sku;
  final int maxOrderQuantity; // Maximum order quantity limit
  final bool requiresShipping; // Requires shipping
  // + shipping dimensions, warranty, etc.
}

// Extended shipping address (customization)
class ExtendedShippingAddressEntity extends ShippingAddressEntity {
  final bool isDefault;
  final String addressType; // home, office, other
  final String deliveryInstructions; // Delivery instructions
  final double latitude;
  final double longitude;
}
```

### Digital Products Marketplace
```dart
class DigitalProductEntity extends MarketplaceProductEntity {
  final String downloadUrl;
  final String licenseType;
  final List<String> fileFormats;
  final int downloadCount;
  final bool hasPreview;
  // + version history, compatibility, etc.
}
```

### Service Marketplace
```dart
class ServiceProductEntity extends MarketplaceProductEntity {
  final double hourlyRate;
  final int estimatedHours;
  final List<String> skillsRequired;
  final bool isRemote;
  final DateTime availableFrom;
  // + portfolio, certifications, etc.
}
```

## Implementation Guidelines for AI

### Planning Questions to Ask
1. **What types of products will be sold in the marketplace?**
2. **Are they offline products (physical) or digital products?**
3. **Do sellers need inventory management tools?**
4. **Are shipping-related features needed?**
5. **What payment methods need to be supported beyond Stripe?**
6. **Do customers need order tracking and delivery updates?**

### Development Approach
1. Start with core product catalog and cart functionality
2. Add inventory management and shipping address features for offline products
3. Integrate with existing payment system for checkout processing
4. Add order management and tracking features (including order confirmation screen)
5. Implement seller tools and dashboard
6. Add customizations incrementally based on requirements
7. Follow existing project architecture and UI patterns
8. Test payment integration thoroughly before adding complex features
9. Ensure App Store compliance features are always included

This flexible approach allows the same marketplace foundation to power diverse e-commerce applications while maintaining code quality, user experience standards, and seamless integration with existing payment infrastructure.