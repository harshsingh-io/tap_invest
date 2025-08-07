import 'package:flutter_test/flutter_test.dart';
import 'package:tap_invest/data/models/bond_summary_model.dart';

void main() {
  group('BondSummary', () {
    group('fromJson', () {
      test('creates BondSummary from valid JSON', () {
        // Arrange
        final json = {
          'logo': 'https://example.com/logo.png',
          'isin': 'INE123A01012',
          'rating': 'AAA',
          'company_name': 'Test Company',
          'tags': ['Technology', 'Growth'],
        };

        // Act
        final bondSummary = BondSummary.fromJson(json);

        // Assert
        expect(bondSummary.logo, equals('https://example.com/logo.png'));
        expect(bondSummary.isin, equals('INE123A01012'));
        expect(bondSummary.rating, equals('AAA'));
        expect(bondSummary.companyName, equals('Test Company'));
        expect(bondSummary.tags, equals(['Technology', 'Growth']));
      });

      test('creates BondSummary with empty tags list', () {
        // Arrange
        final json = {
          'logo': 'https://example.com/logo.png',
          'isin': 'INE123A01012',
          'rating': 'AAA',
          'company_name': 'Test Company',
          'tags': <String>[],
        };

        // Act
        final bondSummary = BondSummary.fromJson(json);

        // Assert
        expect(bondSummary.tags, isEmpty);
      });

      test('handles single tag in tags list', () {
        // Arrange
        final json = {
          'logo': 'https://example.com/logo.png',
          'isin': 'INE123A01012',
          'rating': 'AAA',
          'company_name': 'Test Company',
          'tags': ['Technology'],
        };

        // Act
        final bondSummary = BondSummary.fromJson(json);

        // Assert
        expect(bondSummary.tags.length, equals(1));
        expect(bondSummary.tags.first, equals('Technology'));
      });

      test('throws exception when required field is missing', () {
        // Arrange
        final json = {
          'logo': 'https://example.com/logo.png',
          'isin': 'INE123A01012',
          'rating': 'AAA',
          // Missing company_name
          'tags': ['Technology'],
        };

        // Act & Assert
        expect(() => BondSummary.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('throws exception when field type is incorrect', () {
        // Arrange
        final json = {
          'logo': 'https://example.com/logo.png',
          'isin': 'INE123A01012',
          'rating': 'AAA',
          'company_name': 123, // Should be String
          'tags': ['Technology'],
        };

        // Act & Assert
        expect(() => BondSummary.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('toJson', () {
      test('converts BondSummary to JSON correctly', () {
        // Arrange
        const bondSummary = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: ['Technology', 'Growth'],
        );

        // Act
        final json = bondSummary.toJson();

        // Assert
        expect(json['logo'], equals('https://example.com/logo.png'));
        expect(json['isin'], equals('INE123A01012'));
        expect(json['rating'], equals('AAA'));
        expect(json['company_name'], equals('Test Company'));
        expect(json['tags'], equals(['Technology', 'Growth']));
      });

      test('converts BondSummary with empty tags to JSON', () {
        // Arrange
        const bondSummary = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: [],
        );

        // Act
        final json = bondSummary.toJson();

        // Assert
        expect(json['tags'], isEmpty);
      });
    });

    group('equality', () {
      test('two BondSummary objects with same values are equal', () {
        // Arrange
        const bondSummary1 = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: ['Technology', 'Growth'],
        );

        const bondSummary2 = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: ['Technology', 'Growth'],
        );

        // Act & Assert
        expect(bondSummary1, equals(bondSummary2));
        expect(bondSummary1.hashCode, equals(bondSummary2.hashCode));
      });

      test('two BondSummary objects with different values are not equal', () {
        // Arrange
        const bondSummary1 = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: ['Technology', 'Growth'],
        );

        const bondSummary2 = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE456B01023', // Different ISIN
          rating: 'AAA',
          companyName: 'Test Company',
          tags: ['Technology', 'Growth'],
        );

        // Act & Assert
        expect(bondSummary1, isNot(equals(bondSummary2)));
        expect(bondSummary1.hashCode, isNot(equals(bondSummary2.hashCode)));
      });

      test('BondSummary objects with different tag order are not equal', () {
        // Arrange
        const bondSummary1 = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: ['Technology', 'Growth'],
        );

        const bondSummary2 = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: ['Growth', 'Technology'], // Different order
        );

        // Act & Assert
        expect(bondSummary1, isNot(equals(bondSummary2)));
      });
    });

    group('copyWith', () {
      test('creates copy with modified values', () {
        // Arrange
        const original = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: ['Technology', 'Growth'],
        );

        // Act
        final modified = original.copyWith(
          rating: 'AA+',
          companyName: 'Modified Company',
        );

        // Assert
        expect(modified.logo, equals(original.logo));
        expect(modified.isin, equals(original.isin));
        expect(modified.rating, equals('AA+'));
        expect(modified.companyName, equals('Modified Company'));
        expect(modified.tags, equals(original.tags));
      });

      test('creates copy with same values when no parameters provided', () {
        // Arrange
        const original = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: ['Technology', 'Growth'],
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, equals(original));
      });
    });

    group('toString', () {
      test('returns meaningful string representation', () {
        // Arrange
        const bondSummary = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: ['Technology', 'Growth'],
        );

        // Act
        final stringRepresentation = bondSummary.toString();

        // Assert
        expect(stringRepresentation, contains('BondSummary'));
        expect(stringRepresentation, contains('INE123A01012'));
        expect(stringRepresentation, contains('Test Company'));
        expect(stringRepresentation, contains('AAA'));
      });
    });

    group('JSON round trip', () {
      test(
        'maintains data integrity through JSON serialization/deserialization',
        () {
          // Arrange
          const original = BondSummary(
            logo: 'https://example.com/logo.png',
            isin: 'INE123A01012',
            rating: 'AAA',
            companyName: 'Test Company',
            tags: ['Technology', 'Growth'],
          );

          // Act
          final json = original.toJson();
          final restored = BondSummary.fromJson(json);

          // Assert
          expect(restored, equals(original));
        },
      );

      test('handles special characters in company name', () {
        // Arrange
        const bondSummary = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test & Co. Ltd.',
          tags: ['Finance'],
        );

        // Act
        final json = bondSummary.toJson();
        final restored = BondSummary.fromJson(json);

        // Assert
        expect(restored.companyName, equals('Test & Co. Ltd.'));
        expect(restored, equals(bondSummary));
      });

      test('handles Unicode characters in tags', () {
        // Arrange
        const bondSummary = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: ['तकनीकी', 'वृद्धि'], // Hindi characters
        );

        // Act
        final json = bondSummary.toJson();
        final restored = BondSummary.fromJson(json);

        // Assert
        expect(restored.tags, equals(['तकनीकी', 'वृद्धि']));
        expect(restored, equals(bondSummary));
      });
    });

    group('edge cases', () {
      test('handles very long company name', () {
        // Arrange
        final longName = 'A' * 1000; // Very long company name
        final bondSummary = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: longName,
          tags: ['Technology'],
        );

        // Act
        final json = bondSummary.toJson();
        final restored = BondSummary.fromJson(json);

        // Assert
        expect(restored.companyName, equals(longName));
        expect(restored.companyName.length, equals(1000));
      });

      test('handles many tags', () {
        // Arrange
        final manyTags = List.generate(100, (index) => 'Tag$index');
        final bondSummary = BondSummary(
          logo: 'https://example.com/logo.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company',
          tags: manyTags,
        );

        // Act
        final json = bondSummary.toJson();
        final restored = BondSummary.fromJson(json);

        // Assert
        expect(restored.tags.length, equals(100));
        expect(restored.tags, equals(manyTags));
      });
    });
  });
}
