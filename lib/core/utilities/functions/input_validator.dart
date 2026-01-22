/// Input validation utilities
/// Provides security-focused input validation for forms
///
/// Security Fix: CWE-20 (Improper Input Validation)
/// CVSS Score: 5.3 (Medium)
class InputValidator {
  // Email validation regex (RFC 5322 simplified)
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Password strength regex patterns
  static final _hasUpperCase = RegExp(r'[A-Z]');
  static final _hasLowerCase = RegExp(r'[a-z]');
  static final _hasDigit = RegExp(r'[0-9]');
  static final _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  // Phone number validation (supports international format)
  static final _phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');

  // URL validation
  static final _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return 'Email cannot be empty';
    }

    if (trimmed.length > 254) {
      return 'Email is too long';
    }

    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password with security requirements
  static String? validatePassword(
    String? value, {
    int minLength = 8,
    int maxLength = 128,
    bool requireUpperCase = true,
    bool requireLowerCase = true,
    bool requireDigit = true,
    bool requireSpecialChar = false,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return 'Password is too long (max $maxLength characters)';
    }

    if (requireUpperCase && !_hasUpperCase.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (requireLowerCase && !_hasLowerCase.hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (requireDigit && !_hasDigit.hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (requireSpecialChar && !_hasSpecialChar.hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmation) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate name (alphanumeric + spaces, no special chars)
  static String? validateName(
    String? value, {
    int minLength = 2,
    int maxLength = 50,
  }) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return 'Name cannot be empty';
    }

    if (trimmed.length < minLength) {
      return 'Name must be at least $minLength characters';
    }

    if (trimmed.length > maxLength) {
      return 'Name is too long (max $maxLength characters)';
    }

    // Allow letters, spaces, and Arabic characters
    final nameRegex = RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$');
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!_phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    final trimmed = value.trim();

    if (!_urlRegex.hasMatch(trimmed)) {
      return 'Please enter a valid URL';
    }

    // Security: Ensure HTTPS in production
    if (!trimmed.startsWith('https://')) {
      return 'URL must use HTTPS';
    }

    return null;
  }

  /// Validate required field (generic)
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate length
  static String? validateLength(
    String? value, {
    required int min,
    required int max,
    String? fieldName,
  }) {
    if (value == null) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }

    if (value.length > max) {
      return '${fieldName ?? 'This field'} must be at most $max characters';
    }

    return null;
  }

  /// Sanitize input (remove potentially dangerous characters)
  /// Use this before sending data to API to prevent injection attacks
  static String sanitize(String input) {
    // Remove null bytes
    var sanitized = input.replaceAll('\u0000', '');

    // Remove control characters except newline and tab
    sanitized = sanitized.replaceAll(
      RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]'),
      '',
    );

    // Trim whitespace
    sanitized = sanitized.trim();

    return sanitized;
  }

  /// Validate age (13+ for COPPA compliance)
  static String? validateAge(DateTime? birthDate, {int minimumAge = 13}) {
    if (birthDate == null) {
      return 'Birth date is required';
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year;

    if (birthDate.isAfter(now)) {
      return 'Birth date cannot be in the future';
    }

    if (age < minimumAge) {
      return 'You must be at least $minimumAge years old';
    }

    if (age > 150) {
      return 'Please enter a valid birth date';
    }

    return null;
  }

  /// Check password strength
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength.none;
    }

    int score = 0;

    // Length
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;

    // Character variety
    if (_hasUpperCase.hasMatch(password)) score++;
    if (_hasLowerCase.hasMatch(password)) score++;
    if (_hasDigit.hasMatch(password)) score++;
    if (_hasSpecialChar.hasMatch(password)) score++;

    // Return strength based on score
    if (score < 3) return PasswordStrength.weak;
    if (score < 5) return PasswordStrength.medium;
    if (score < 7) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }
}

/// Password strength enum
enum PasswordStrength {
  none,
  weak,
  medium,
  strong,
  veryStrong,
}
