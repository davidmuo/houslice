import 'package:flutter_test/flutter_test.dart';
import 'package:houslice/core/utils/validators.dart';

/// Unit tests for the form rules that gate registration to verified students.
void main() {
  group('Validators.email', () {
    test('rejects an empty value', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email(null), 'Email is required');
    });

    test('rejects a malformed address', () {
      expect(Validators.email('not-an-email'), 'Enter a valid email address');
      expect(Validators.email('missing@domain'), 'Enter a valid email address');
    });

    test('accepts a well-formed address from any domain', () {
      expect(Validators.email('someone@gmail.com'), isNull);
      expect(Validators.email('  spaced@example.co.uk  '), isNull);
    });
  });

  group('Validators.studentEmail', () {
    test('accepts every allowed university domain', () {
      for (final domain in Validators.allowedDomains) {
        expect(
          Validators.studentEmail('student@$domain'),
          isNull,
          reason: '$domain should be accepted',
        );
      }
    });

    test('is case-insensitive about the domain', () {
      expect(Validators.studentEmail('Student@ALUSTUDENT.COM'), isNull);
    });

    test('rejects a non-university domain', () {
      expect(
        Validators.studentEmail('student@gmail.com'),
        'Use your university email (e.g. name@alustudent.com)',
      );
    });

    test('reports the basic format problem before the domain rule', () {
      expect(
        Validators.studentEmail('nonsense'),
        'Enter a valid email address',
      );
    });
  });

  group('Validators.password', () {
    test('requires at least six characters', () {
      expect(
        Validators.password('12345'),
        'Password must be at least 6 characters',
      );
      expect(Validators.password('123456'), isNull);
    });

    test('confirmPassword fails when the two do not match', () {
      expect(
        Validators.confirmPassword('password123', 'password124'),
        'Passwords do not match',
      );
      expect(Validators.confirmPassword('password123', 'password123'), isNull);
    });
  });

  group('Validators.username', () {
    test('requires at least three characters after trimming', () {
      expect(Validators.username('  '), 'Username is required');
      expect(
        Validators.username('ab'),
        'Username must be at least 3 characters',
      );
      expect(Validators.username('abc'), isNull);
    });
  });
}
