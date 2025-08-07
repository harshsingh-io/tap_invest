import 'package:flutter_test/flutter_test.dart';
import 'package:tap_invest/data/models/bond_detail_model.dart';

void main() {
  group('BondDetail', () {
    group('fromJson', () {
      test('creates BondDetail from valid JSON', () {
        // Arrange
        final json = {
          'logo': 'https://example.com/logo.png',
          'company_name': 'Test Company',
          'description': 'A test company for unit testing',
          'isin': 'INE123A01012',
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

        // Act
        final bondDetail = BondDetail.fromJson(json);

        // Assert
        expect(bondDetail.logo, equals('https://example.com/logo.png'));
        expect(bondDetail.companyName, equals('Test Company'));
        expect(
          bondDetail.description,
          equals('A test company for unit testing'),
        );
        expect(bondDetail.isin, equals('INE123A01012'));
        expect(bondDetail.status, equals('Active'));
        expect(
          bondDetail.prosAndCons.pros,
          equals(['Strong financials', 'Market leader']),
        );
        expect(
          bondDetail.prosAndCons.cons,
          equals(['High competition', 'Regulatory risks']),
        );
        expect(bondDetail.financials.ebitda.length, equals(2));
        expect(bondDetail.financials.revenue.length, equals(2));
        expect(bondDetail.issuerDetails.issuerName, equals('Test Issuer'));
      });

      test('handles null lead manager in issuer details', () {
        // Arrange
        final json = {
          'logo': 'https://example.com/logo.png',
          'company_name': 'Test Company',
          'description': 'A test company',
          'isin': 'INE123A01012',
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
            'lead_manager': null,
            'registrar': 'Test Registrar',
            'debenture_trustee': 'Test Debenture Trustee',
          },
        };

        // Act
        final bondDetail = BondDetail.fromJson(json);

        // Assert
        expect(bondDetail.issuerDetails.leadManager, isNull);
        expect(bondDetail.issuerDetails.registrar, equals('Test Registrar'));
      });

      test('throws exception when required field is missing', () {
        // Arrange
        final json = {
          'logo': 'https://example.com/logo.png',
          'company_name': 'Test Company',
          // Missing description
          'isin': 'INE123A01012',
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
            'lead_manager': null,
            'registrar': 'Test Registrar',
            'debenture_trustee': 'Test Debenture Trustee',
          },
        };

        // Act & Assert
        expect(() => BondDetail.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('equality', () {
      test('two BondDetail objects with same values are equal', () {
        // Arrange
        const bondDetail1 = BondDetail(
          logo: 'https://example.com/logo.png',
          companyName: 'Test Company',
          description: 'A test company',
          isin: 'INE123A01012',
          status: 'Active',
          prosAndCons: ProsAndCons(
            pros: ['Strong financials'],
            cons: ['High competition'],
          ),
          financials: Financials(
            ebitda: [FinancialDataPoint(month: 'Jan', value: 1000)],
            revenue: [FinancialDataPoint(month: 'Jan', value: 5000)],
          ),
          issuerDetails: IssuerDetails(
            issuerName: 'Test Issuer',
            typeOfIssuer: 'Corporation',
            sector: 'Technology',
            industry: 'Software',
            issuerNature: 'Private',
            cin: 'L12345MH2020PLC123456',
            leadManager: null,
            registrar: 'Test Registrar',
            debentureTrustee: 'Test Trustee',
          ),
        );

        const bondDetail2 = BondDetail(
          logo: 'https://example.com/logo.png',
          companyName: 'Test Company',
          description: 'A test company',
          isin: 'INE123A01012',
          status: 'Active',
          prosAndCons: ProsAndCons(
            pros: ['Strong financials'],
            cons: ['High competition'],
          ),
          financials: Financials(
            ebitda: [FinancialDataPoint(month: 'Jan', value: 1000)],
            revenue: [FinancialDataPoint(month: 'Jan', value: 5000)],
          ),
          issuerDetails: IssuerDetails(
            issuerName: 'Test Issuer',
            typeOfIssuer: 'Corporation',
            sector: 'Technology',
            industry: 'Software',
            issuerNature: 'Private',
            cin: 'L12345MH2020PLC123456',
            leadManager: null,
            registrar: 'Test Registrar',
            debentureTrustee: 'Test Trustee',
          ),
        );

        // Act & Assert
        expect(bondDetail1, equals(bondDetail2));
        expect(bondDetail1.hashCode, equals(bondDetail2.hashCode));
      });

      test('two BondDetail objects with different values are not equal', () {
        // Arrange
        const bondDetail1 = BondDetail(
          logo: 'https://example.com/logo.png',
          companyName: 'Test Company',
          description: 'A test company',
          isin: 'INE123A01012',
          status: 'Active',
          prosAndCons: ProsAndCons(
            pros: ['Strong financials'],
            cons: ['High competition'],
          ),
          financials: Financials(
            ebitda: [FinancialDataPoint(month: 'Jan', value: 1000)],
            revenue: [FinancialDataPoint(month: 'Jan', value: 5000)],
          ),
          issuerDetails: IssuerDetails(
            issuerName: 'Test Issuer',
            typeOfIssuer: 'Corporation',
            sector: 'Technology',
            industry: 'Software',
            issuerNature: 'Private',
            cin: 'L12345MH2020PLC123456',
            leadManager: null,
            registrar: 'Test Registrar',
            debentureTrustee: 'Test Trustee',
          ),
        );

        const bondDetail2 = BondDetail(
          logo: 'https://example.com/logo.png',
          companyName: 'Different Company', // Different company name
          description: 'A test company',
          isin: 'INE123A01012',
          status: 'Active',
          prosAndCons: ProsAndCons(
            pros: ['Strong financials'],
            cons: ['High competition'],
          ),
          financials: Financials(
            ebitda: [FinancialDataPoint(month: 'Jan', value: 1000)],
            revenue: [FinancialDataPoint(month: 'Jan', value: 5000)],
          ),
          issuerDetails: IssuerDetails(
            issuerName: 'Test Issuer',
            typeOfIssuer: 'Corporation',
            sector: 'Technology',
            industry: 'Software',
            issuerNature: 'Private',
            cin: 'L12345MH2020PLC123456',
            leadManager: null,
            registrar: 'Test Registrar',
            debentureTrustee: 'Test Trustee',
          ),
        );

        // Act & Assert
        expect(bondDetail1, isNot(equals(bondDetail2)));
      });
    });
  });

  group('ProsAndCons', () {
    group('fromJson', () {
      test('creates ProsAndCons from valid JSON', () {
        // Arrange
        final json = {
          'pros': ['Strong financials', 'Market leader'],
          'cons': ['High competition', 'Regulatory risks'],
        };

        // Act
        final prosAndCons = ProsAndCons.fromJson(json);

        // Assert
        expect(
          prosAndCons.pros,
          equals(['Strong financials', 'Market leader']),
        );
        expect(
          prosAndCons.cons,
          equals(['High competition', 'Regulatory risks']),
        );
      });

      test('creates ProsAndCons with empty lists', () {
        // Arrange
        final json = {'pros': <String>[], 'cons': <String>[]};

        // Act
        final prosAndCons = ProsAndCons.fromJson(json);

        // Assert
        expect(prosAndCons.pros, isEmpty);
        expect(prosAndCons.cons, isEmpty);
      });
    });

    group('equality', () {
      test('two ProsAndCons objects with same values are equal', () {
        // Arrange
        const prosAndCons1 = ProsAndCons(
          pros: ['Strong financials'],
          cons: ['High competition'],
        );

        const prosAndCons2 = ProsAndCons(
          pros: ['Strong financials'],
          cons: ['High competition'],
        );

        // Act & Assert
        expect(prosAndCons1, equals(prosAndCons2));
      });
    });
  });

  group('Financials', () {
    group('fromJson', () {
      test('creates Financials from valid JSON', () {
        // Arrange
        final json = {
          'ebitda': [
            {'month': 'Jan', 'value': 1000},
            {'month': 'Feb', 'value': 1200},
          ],
          'revenue': [
            {'month': 'Jan', 'value': 5000},
            {'month': 'Feb', 'value': 5500},
          ],
        };

        // Act
        final financials = Financials.fromJson(json);

        // Assert
        expect(financials.ebitda.length, equals(2));
        expect(financials.revenue.length, equals(2));
        expect(financials.ebitda[0].month, equals('Jan'));
        expect(financials.ebitda[0].value, equals(1000));
      });
    });
  });

  group('FinancialDataPoint', () {
    group('fromJson', () {
      test('creates FinancialDataPoint from valid JSON', () {
        // Arrange
        final json = {'month': 'January', 'value': 1500};

        // Act
        final dataPoint = FinancialDataPoint.fromJson(json);

        // Assert
        expect(dataPoint.month, equals('January'));
        expect(dataPoint.value, equals(1500));
      });
    });

    group('equality', () {
      test('two FinancialDataPoint objects with same values are equal', () {
        // Arrange
        const dataPoint1 = FinancialDataPoint(month: 'Jan', value: 1000);
        const dataPoint2 = FinancialDataPoint(month: 'Jan', value: 1000);

        // Act & Assert
        expect(dataPoint1, equals(dataPoint2));
      });

      test(
        'two FinancialDataPoint objects with different values are not equal',
        () {
          // Arrange
          const dataPoint1 = FinancialDataPoint(month: 'Jan', value: 1000);
          const dataPoint2 = FinancialDataPoint(month: 'Feb', value: 1000);

          // Act & Assert
          expect(dataPoint1, isNot(equals(dataPoint2)));
        },
      );
    });
  });

  group('IssuerDetails', () {
    group('fromJson', () {
      test('creates IssuerDetails from valid JSON with lead manager', () {
        // Arrange
        final json = {
          'issuer_name': 'Test Issuer',
          'type_of_issuer': 'Corporation',
          'sector': 'Technology',
          'industry': 'Software',
          'issuer_nature': 'Private',
          'cin': 'L12345MH2020PLC123456',
          'lead_manager': 'Test Lead Manager',
          'registrar': 'Test Registrar',
          'debenture_trustee': 'Test Debenture Trustee',
        };

        // Act
        final issuerDetails = IssuerDetails.fromJson(json);

        // Assert
        expect(issuerDetails.issuerName, equals('Test Issuer'));
        expect(issuerDetails.typeOfIssuer, equals('Corporation'));
        expect(issuerDetails.sector, equals('Technology'));
        expect(issuerDetails.industry, equals('Software'));
        expect(issuerDetails.issuerNature, equals('Private'));
        expect(issuerDetails.cin, equals('L12345MH2020PLC123456'));
        expect(issuerDetails.leadManager, equals('Test Lead Manager'));
        expect(issuerDetails.registrar, equals('Test Registrar'));
      });

      test('creates IssuerDetails from valid JSON with null lead manager', () {
        // Arrange
        final json = {
          'issuer_name': 'Test Issuer',
          'type_of_issuer': 'Corporation',
          'sector': 'Technology',
          'industry': 'Software',
          'issuer_nature': 'Private',
          'cin': 'L12345MH2020PLC123456',
          'lead_manager': null,
          'registrar': 'Test Registrar',
          'debenture_trustee': 'Test Debenture Trustee',
        };

        // Act
        final issuerDetails = IssuerDetails.fromJson(json);

        // Assert
        expect(issuerDetails.leadManager, isNull);
        expect(issuerDetails.registrar, equals('Test Registrar'));
      });
    });

    group('equality', () {
      test('two IssuerDetails objects with same values are equal', () {
        // Arrange
        const issuerDetails1 = IssuerDetails(
          issuerName: 'Test Issuer',
          typeOfIssuer: 'Corporation',
          sector: 'Technology',
          industry: 'Software',
          issuerNature: 'Private',
          cin: 'L12345MH2020PLC123456',
          leadManager: 'Test Lead Manager',
          registrar: 'Test Registrar',
          debentureTrustee: 'Test Trustee',
        );

        const issuerDetails2 = IssuerDetails(
          issuerName: 'Test Issuer',
          typeOfIssuer: 'Corporation',
          sector: 'Technology',
          industry: 'Software',
          issuerNature: 'Private',
          cin: 'L12345MH2020PLC123456',
          leadManager: 'Test Lead Manager',
          registrar: 'Test Registrar',
          debentureTrustee: 'Test Trustee',
        );

        // Act & Assert
        expect(issuerDetails1, equals(issuerDetails2));
      });
    });
  });

  group('JSON round trip', () {});
}
