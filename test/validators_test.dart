import 'package:flutter_test/flutter_test.dart';
import 'package:core_app/core/utils/validators.dart';

void main() {
  group('AppValidators', () {
    test('validateEmail returns null for valid email addresses', () {
      expect(AppValidators.validateEmail('demo@coreapp.com'), isNull);
      expect(AppValidators.validateEmail('user.name+tag@sub.domain.co'), isNull);
    });

    test('validateEmail returns error for empty or invalid emails', () {
      expect(AppValidators.validateEmail(null), isNotNull);
      expect(AppValidators.validateEmail(''), isNotNull);
      expect(AppValidators.validateEmail('   '), isNotNull);
      expect(AppValidators.validateEmail('notanemail'), isNotNull);
      expect(AppValidators.validateEmail('missing@domain'), isNotNull);
    });

    test('validatePassword returns null for passwords with 6 or more characters', () {
      expect(AppValidators.validatePassword('123456'), isNull);
      expect(AppValidators.validatePassword('password123'), isNull);
    });

    test('validatePassword returns error for short or empty passwords', () {
      expect(AppValidators.validatePassword(null), isNotNull);
      expect(AppValidators.validatePassword(''), isNotNull);
      expect(AppValidators.validatePassword('12345'), isNotNull);
    });

    test('validateRequired validates presence of non-empty text', () {
      expect(AppValidators.validateRequired('John Doe', 'name'), isNull);
      expect(AppValidators.validateRequired('', 'name'), isNotNull);
      expect(AppValidators.validateRequired('   ', 'name'), isNotNull);
      expect(AppValidators.validateRequired(null, 'name'), isNotNull);
    });
  });
}
