import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tap_invest/data/repository/bond_repository.dart';
import 'package:tap_invest/data/models/bond_summary_model.dart';
import 'package:tap_invest/data/models/bond_detail_model.dart';

import 'bond_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('BondRepositoryImpl', () {
    late MockDio mockDio;
    late BondRepositoryImpl repository;

    setUp(() {
      mockDio = MockDio();
      repository = BondRepositoryImpl(mockDio);
    });

    group('getBonds', () {
      test('returns list of BondSummary when API call succeeds', () async {
        // Arrange
        final mockResponseData = {
          'data': [
            {
              'logo': 'https://example.com/logo1.png',
              'isin': 'INE123A01012',
              'rating': 'AAA',
              'company_name': 'Test Company 1',
              'tags': ['Technology', 'Growth'],
            },
            {
              'logo': 'https://example.com/logo2.png',
              'isin': 'INE456B01023',
              'rating': 'AA+',
              'company_name': 'Test Company 2',
              'tags': ['Finance', 'Stable'],
            },
          ],
        };

        final mockResponse = Response(
          data: mockResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.get('https://eol122duf9sy4de.m.pipedream.net'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.getBonds();

        // Assert
        expect(result, isA<List<BondSummary>>());
        expect(result.length, equals(2));

        expect(result[0].isin, equals('INE123A01012'));
        expect(result[0].companyName, equals('Test Company 1'));
        expect(result[0].rating, equals('AAA'));
        expect(result[0].tags, equals(['Technology', 'Growth']));

        expect(result[1].isin, equals('INE456B01023'));
        expect(result[1].companyName, equals('Test Company 2'));
        expect(result[1].rating, equals('AA+'));
        expect(result[1].tags, equals(['Finance', 'Stable']));

        verify(
          mockDio.get('https://eol122duf9sy4de.m.pipedream.net'),
        ).called(1);
      });

      test('returns empty list when API returns empty data array', () async {
        // Arrange
        final mockResponseData = {'data': []};
        final mockResponse = Response(
          data: mockResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.get('https://eol122duf9sy4de.m.pipedream.net'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.getBonds();

        // Assert
        expect(result, isEmpty);
        verify(
          mockDio.get('https://eol122duf9sy4de.m.pipedream.net'),
        ).called(1);
      });

      test('throws Exception when API call fails with DioException', () async {
        // Arrange
        when(mockDio.get('https://eol122duf9sy4de.m.pipedream.net')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => repository.getBonds(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load bonds'),
            ),
          ),
        );

        verify(
          mockDio.get('https://eol122duf9sy4de.m.pipedream.net'),
        ).called(1);
      });

      test(
        'throws Exception when API returns invalid JSON structure',
        () async {
          // Arrange
          final mockResponseData = {'invalid': 'structure'};
          final mockResponse = Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          );

          when(
            mockDio.get('https://eol122duf9sy4de.m.pipedream.net'),
          ).thenAnswer((_) async => mockResponse);

          // Act & Assert
          expect(
            () => repository.getBonds(),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Failed to load bonds'),
              ),
            ),
          );
        },
      );

      test('throws Exception when network timeout occurs', () async {
        // Arrange
        when(mockDio.get('https://eol122duf9sy4de.m.pipedream.net')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act & Assert
        expect(() => repository.getBonds(), throwsA(isA<Exception>()));
      });
    });

    group('getBondDetail', () {
      const testIsin = 'INE123A01012';

      test('returns BondDetail when API call succeeds', () async {
        // Arrange
        final mockResponseData = {
          'logo': 'https://example.com/logo.png',
          'company_name': 'Test Company',
          'description': 'A test company for unit testing',
          'isin': testIsin,
          'status': 'Active',
          'pros_and_cons': {
            'pros': ['Strong financials', 'Market leader'],
            'cons': ['High competition', 'Regulatory risks'],
          },
          'financials': {
            'ebitda': [
              {'month': 'Jan', 'value': 1000},
              {'month': 'Feb', 'value': 1200},
            ],
            'revenue': [
              {'month': 'Jan', 'value': 5000},
              {'month': 'Feb', 'value': 5500},
            ],
          },
          'issuer_details': {
            'issuer_name': 'Test Issuer',
            'type_of_issuer': 'Corporation',
            'sector': 'Technology',
            'industry': 'Software',
            'issuer_nature': 'Private',
            'cin': 'L12345MH2020PLC123456',
            'lead_manager': 'Test Lead Manager',
            'registrar': 'Test Registrar',
            'debenture_trustee': 'Test Debenture Trustee',
          },
        };

        final mockResponse = Response(
          data: mockResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.get('https://eo61q3zd4heiwke.m.pipedream.net'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.getBondDetail(testIsin);

        // Assert
        expect(result, isA<BondDetail>());
        expect(result.isin, equals(testIsin));
        expect(result.companyName, equals('Test Company'));
        expect(result.status, equals('Active'));
        expect(result.prosAndCons.pros, contains('Strong financials'));
        expect(result.prosAndCons.cons, contains('High competition'));
        expect(result.financials.ebitda.length, equals(2));
        expect(result.financials.revenue.length, equals(2));
        expect(result.issuerDetails.issuerName, equals('Test Issuer'));

        verify(
          mockDio.get('https://eo61q3zd4heiwke.m.pipedream.net'),
        ).called(1);
      });

      test('throws Exception when API call fails with DioException', () async {
        // Arrange
        when(mockDio.get('https://eo61q3zd4heiwke.m.pipedream.net')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Network error',
          ),
        );

        // Act & Assert
        expect(
          () => repository.getBondDetail(testIsin),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load bond detail'),
            ),
          ),
        );

        verify(
          mockDio.get('https://eo61q3zd4heiwke.m.pipedream.net'),
        ).called(1);
      });

      test('throws Exception when API returns 404', () async {
        // Arrange
        when(mockDio.get('https://eo61q3zd4heiwke.m.pipedream.net')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: ''),
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // Act & Assert
        expect(
          () => repository.getBondDetail(testIsin),
          throwsA(isA<Exception>()),
        );
      });

      test(
        'throws Exception when API returns invalid JSON structure',
        () async {
          // Arrange
          final mockResponseData = {'invalid': 'structure'};
          final mockResponse = Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          );

          when(
            mockDio.get('https://eo61q3zd4heiwke.m.pipedream.net'),
          ).thenAnswer((_) async => mockResponse);

          // Act & Assert
          expect(
            () => repository.getBondDetail(testIsin),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Failed to load bond detail'),
              ),
            ),
          );
        },
      );

      test('handles null lead manager in issuer details', () async {
        // Arrange
        final mockResponseData = {
          'logo': 'https://example.com/logo.png',
          'company_name': 'Test Company',
          'description': 'A test company',
          'isin': testIsin,
          'status': 'Active',
          'pros_and_cons': {
            'pros': ['Strong financials'],
            'cons': ['High competition'],
          },
          'financials': {
            'ebitda': [
              {'month': 'Jan', 'value': 1000},
            ],
            'revenue': [
              {'month': 'Jan', 'value': 5000},
            ],
          },
          'issuer_details': {
            'issuer_name': 'Test Issuer',
            'type_of_issuer': 'Corporation',
            'sector': 'Technology',
            'industry': 'Software',
            'issuer_nature': 'Private',
            'cin': 'L12345MH2020PLC123456',
            'lead_manager': null, // Null lead manager
            'registrar': 'Test Registrar',
            'debenture_trustee': 'Test Debenture Trustee',
          },
        };

        final mockResponse = Response(
          data: mockResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.get('https://eo61q3zd4heiwke.m.pipedream.net'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.getBondDetail(testIsin);

        // Assert
        expect(result.issuerDetails.leadManager, isNull);
        expect(result.issuerDetails.registrar, equals('Test Registrar'));
      });

      test('throws Exception when network connection is lost', () async {
        // Arrange
        when(mockDio.get('https://eo61q3zd4heiwke.m.pipedream.net')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act & Assert
        expect(
          () => repository.getBondDetail(testIsin),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('error handling', () {
      test('handles general Exception properly', () async {
        // Arrange
        when(
          mockDio.get('https://eol122duf9sy4de.m.pipedream.net'),
        ).thenThrow(Exception('Generic error'));

        // Act & Assert
        expect(
          () => repository.getBonds(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load bonds'),
            ),
          ),
        );
      });

      test('handles FormatException when parsing JSON', () async {
        // Arrange
        when(
          mockDio.get('https://eol122duf9sy4de.m.pipedream.net'),
        ).thenThrow(const FormatException('Invalid JSON'));

        // Act & Assert
        expect(() => repository.getBonds(), throwsA(isA<Exception>()));
      });
    });
  });
}
