// ===== File: lib/core/validator.dart =====
// Validator.email(value) 이렇게 적으세요.

// ----- How to use ---------------------------------------------------
/// Collection of static helper methods for validating text-field inputs.
///
/// Common usage patterns:
///
///   // 1. Direct invocation
///   final emailError = Validators.email('test@domain.com');
///   if (emailError != null) {
///     // Handle error (e.g., show Snackbar)
///   }
///
///   // 2. Inside a TextFormField
///   TextFormField(
///     decoration: const InputDecoration(labelText: 'Email'),
///     validator: Validators.email, // <-- just pass the reference
///   );
///
///   // 3. Validate on-the-fly
///   final isValid = Validators.password(myPassword) == null;
///
/// Available validators:
///   • email
///   • password
///   • phone
///   • name
///   • required
///
/// All methods return `null` when the value is valid, otherwise a localized
/// error message string.
// -------------------------------------------------------------------
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    } else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    } else if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    } else if (value.trim().length > 20) {
      return 'Name must be less than 20 characters';
    } else if (value.contains(' ')) {
      return 'Name cannot contain spaces';
    }
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}
