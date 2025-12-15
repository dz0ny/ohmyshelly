import 'dart:convert';

/// Utility class for working with JWT tokens
class JwtUtils {
  /// Decode the payload from a JWT token
  /// Returns null if the token is invalid
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Payload is the second part
      final payload = parts[1];

      // Add padding if needed (base64 requires length divisible by 4)
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Get the expiration time from a JWT token
  /// Returns null if the token is invalid or has no expiration
  static DateTime? getExpiration(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    final exp = payload['exp'];
    if (exp == null) return null;

    // exp is in seconds since epoch
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    }

    return null;
  }

  /// Check if a token is expired
  static bool isExpired(String token) {
    final expiration = getExpiration(token);
    if (expiration == null) return true; // Treat invalid tokens as expired

    return DateTime.now().isAfter(expiration);
  }

  /// Check if a token will expire within the given duration
  static bool willExpireSoon(String token, {Duration margin = const Duration(minutes: 5)}) {
    final expiration = getExpiration(token);
    if (expiration == null) return true; // Treat invalid tokens as expiring soon

    final expirationWithMargin = expiration.subtract(margin);
    return DateTime.now().isAfter(expirationWithMargin);
  }

  /// Get the remaining time until token expiration
  /// Returns null if the token is invalid or already expired
  static Duration? getTimeUntilExpiration(String token) {
    final expiration = getExpiration(token);
    if (expiration == null) return null;

    final remaining = expiration.difference(DateTime.now());
    if (remaining.isNegative) return null;

    return remaining;
  }

  /// Get human-readable time until expiration
  static String? getExpirationString(String token) {
    final remaining = getTimeUntilExpiration(token);
    if (remaining == null) return 'Expired';

    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h';
    }
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    }
    if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m';
    }
    return '${remaining.inSeconds}s';
  }
}
