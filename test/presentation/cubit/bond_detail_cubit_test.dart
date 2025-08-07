import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tap_invest/data/repository/bond_repository.dart';
import 'package:tap_invest/presentation/cubit/bond_detail_cubit.dart';
import 'package:tap_invest/presentation/cubit/bond_detail_state.dart';
import 'package:tap_invest/data/models/bond_detail_model.dart';

import 'bond_detail_cubit_test.mocks.dart';

@GenerateMocks([BondRepository])
void main() {
  group('BondDetailCubit', () {
    late MockBondRepository mockRepository;
    late BondDetailCubit bondDetailCubit;

    setUp(() {
      mockRepository = MockBondRepository();
      bondDetailCubit = BondDetailCubit(mockRepository);
    });

    tearDown(() {
      bondDetailCubit.close();
    });

    test('initial state is BondDetailState.initial', () {
      expect(bondDetailCubit.state, equals(const BondDetailState.initial()));
    });

    group('fetchDetail', () {
      const testIsin = 'INE123A01012';
      final mockBondDetail = BondDetail(
        logo: 'https://example.com/logo.png',
        companyName: 'Test Company',
        description: 'A test company for unit testing',
        isin: testIsin,
        status: 'Active',
        prosAndCons: const ProsAndCons(
          pros: ['Strong financials', 'Market leader'],
          cons: ['High competition', 'Regulatory risks'],
        ),
        financials: const Financials(
          ebitda: [
            FinancialDataPoint(month: 'Jan', value: 1000),
            FinancialDataPoint(month: 'Feb', value: 1200),
          ],
          revenue: [
            FinancialDataPoint(month: 'Jan', value: 5000),
            FinancialDataPoint(month: 'Feb', value: 5500),
          ],
        ),
        issuerDetails: const IssuerDetails(
          issuerName: 'Test Issuer',
          typeOfIssuer: 'Corporation',
          sector: 'Technology',
          industry: 'Software',
          issuerNature: 'Private',
          cin: 'L12345MH2020PLC123456',
          leadManager: 'Test Lead Manager',
          registrar: 'Test Registrar',
          debentureTrustee: 'Test Trustee',
        ),
      );

      blocTest<BondDetailCubit, BondDetailState>(
        'emits [loading, loaded] when fetchDetail succeeds',
        build: () {
          when(
            mockRepository.getBondDetail(testIsin),
          ).thenAnswer((_) async => mockBondDetail);
          return bondDetailCubit;
        },
        act: (cubit) => cubit.fetchDetail(testIsin),
        expect:
            () => [
              const BondDetailState.loading(),
              BondDetailState.loaded(
                detail: mockBondDetail,
                chartType: FinancialChartType.ebitda,
              ),
            ],
        verify: (_) {
          verify(mockRepository.getBondDetail(testIsin)).called(1);
        },
      );

      blocTest<BondDetailCubit, BondDetailState>(
        'emits [loading, error] when fetchDetail fails',
        build: () {
          when(
            mockRepository.getBondDetail(testIsin),
          ).thenThrow(Exception('Failed to load bond detail'));
          return bondDetailCubit;
        },
        act: (cubit) => cubit.fetchDetail(testIsin),
        expect:
            () => [
              const BondDetailState.loading(),
              const BondDetailState.error(
                'Exception: Failed to load bond detail',
              ),
            ],
        verify: (_) {
          verify(mockRepository.getBondDetail(testIsin)).called(1);
        },
      );

      blocTest<BondDetailCubit, BondDetailState>(
        'emits [loading, error] when repository throws network error',
        build: () {
          when(
            mockRepository.getBondDetail(testIsin),
          ).thenThrow(Exception('Network error'));
          return bondDetailCubit;
        },
        act: (cubit) => cubit.fetchDetail(testIsin),
        expect:
            () => [
              const BondDetailState.loading(),
              const BondDetailState.error('Exception: Network error'),
            ],
      );
    });

    group('toggleChartType', () {
      final mockBondDetail = BondDetail(
        logo: 'https://example.com/logo.png',
        companyName: 'Test Company',
        description: 'A test company for unit testing',
        isin: 'INE123A01012',
        status: 'Active',
        prosAndCons: const ProsAndCons(
          pros: ['Strong financials'],
          cons: ['High competition'],
        ),
        financials: const Financials(
          ebitda: [FinancialDataPoint(month: 'Jan', value: 1000)],
          revenue: [FinancialDataPoint(month: 'Jan', value: 5000)],
        ),
        issuerDetails: const IssuerDetails(
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

      blocTest<BondDetailCubit, BondDetailState>(
        'toggles from EBITDA to Revenue chart type',
        build: () => bondDetailCubit,
        seed:
            () => BondDetailState.loaded(
              detail: mockBondDetail,
              chartType: FinancialChartType.ebitda,
            ),
        act: (cubit) => cubit.toggleChartType(FinancialChartType.revenue),
        expect:
            () => [
              BondDetailState.loaded(
                detail: mockBondDetail,
                chartType: FinancialChartType.revenue,
              ),
            ],
      );

      blocTest<BondDetailCubit, BondDetailState>(
        'toggles from Revenue to EBITDA chart type',
        build: () => bondDetailCubit,
        seed:
            () => BondDetailState.loaded(
              detail: mockBondDetail,
              chartType: FinancialChartType.revenue,
            ),
        act: (cubit) => cubit.toggleChartType(FinancialChartType.ebitda),
        expect:
            () => [
              BondDetailState.loaded(
                detail: mockBondDetail,
                chartType: FinancialChartType.ebitda,
              ),
            ],
      );

      blocTest<BondDetailCubit, BondDetailState>(
        'does not change state when toggling to same chart type',
        build: () => bondDetailCubit,
        seed:
            () => BondDetailState.loaded(
              detail: mockBondDetail,
              chartType: FinancialChartType.ebitda,
            ),
        act: (cubit) => cubit.toggleChartType(FinancialChartType.ebitda),
        expect: () => [],
      );

      test('does nothing when state is not loaded', () {
        // Start with initial state
        bondDetailCubit.toggleChartType(FinancialChartType.revenue);
        expect(bondDetailCubit.state, equals(const BondDetailState.initial()));
      });

      test('does nothing when state is loading', () {
        // Manually set loading state
        bondDetailCubit.emit(const BondDetailState.loading());
        bondDetailCubit.toggleChartType(FinancialChartType.revenue);
        expect(bondDetailCubit.state, equals(const BondDetailState.loading()));
      });

      test('does nothing when state is error', () {
        // Manually set error state
        const errorState = BondDetailState.error('Test error');
        bondDetailCubit.emit(errorState);
        bondDetailCubit.toggleChartType(FinancialChartType.revenue);
        expect(bondDetailCubit.state, equals(errorState));
      });
    });

    group('state persistence', () {
      final mockBondDetail = BondDetail(
        logo: 'https://example.com/logo.png',
        companyName: 'Test Company',
        description: 'A test company for unit testing',
        isin: 'INE123A01012',
        status: 'Active',
        prosAndCons: const ProsAndCons(
          pros: ['Strong financials'],
          cons: ['High competition'],
        ),
        financials: const Financials(
          ebitda: [FinancialDataPoint(month: 'Jan', value: 1000)],
          revenue: [FinancialDataPoint(month: 'Jan', value: 5000)],
        ),
        issuerDetails: const IssuerDetails(
          issuerName: 'Test Issuer',
          typeOfIssuer: 'Corporation',
          sector: 'Technology',
          industry: 'Software',
          issuerNature: 'Private',
          cin: 'L12345MH2020PLC123456',
          leadManager: 'Test Lead Manager',
          registrar: 'Test Registrar',
          debentureTrustee: 'Test Trustee',
        ),
      );

      test('preserves bond detail when toggling chart type', () {
        // Set loaded state
        final loadedState = BondDetailState.loaded(
          detail: mockBondDetail,
          chartType: FinancialChartType.ebitda,
        );
        bondDetailCubit.emit(loadedState);

        // Toggle chart type
        bondDetailCubit.toggleChartType(FinancialChartType.revenue);

        // Verify detail is preserved
        bondDetailCubit.state.whenOrNull(
          loaded: (detail, chartType) {
            expect(detail, equals(mockBondDetail));
            expect(chartType, equals(FinancialChartType.revenue));
          },
        );
      });
    });
  });
}
