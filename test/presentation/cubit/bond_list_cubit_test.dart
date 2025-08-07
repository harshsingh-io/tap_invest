import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tap_invest/data/repository/bond_repository.dart';
import 'package:tap_invest/presentation/cubit/bond_list_cubit.dart';
import 'package:tap_invest/presentation/cubit/bond_list_state.dart';
import 'package:tap_invest/data/models/bond_summary_model.dart';

import 'bond_list_cubit_test.mocks.dart';

@GenerateMocks([BondRepository])
void main() {
  group('BondListCubit', () {
    late MockBondRepository mockRepository;
    late BondListCubit bondListCubit;

    setUp(() {
      mockRepository = MockBondRepository();
      bondListCubit = BondListCubit(mockRepository);
    });

    tearDown(() {
      bondListCubit.close();
    });

    test('initial state is BondListState.initial', () {
      expect(bondListCubit.state, equals(const BondListState.initial()));
    });

    group('fetchBonds', () {
      final mockBonds = [
        const BondSummary(
          logo: 'https://example.com/logo1.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Test Company 1',
          tags: ['Technology', 'Growth'],
        ),
        const BondSummary(
          logo: 'https://example.com/logo2.png',
          isin: 'INE456B01023',
          rating: 'AA+',
          companyName: 'Test Company 2',
          tags: ['Finance', 'Stable'],
        ),
      ];

      blocTest<BondListCubit, BondListState>(
        'emits [loading, loaded] when fetchBonds succeeds',
        build: () {
          when(mockRepository.getBonds()).thenAnswer((_) async => mockBonds);
          return bondListCubit;
        },
        act: (cubit) => cubit.fetchBonds(),
        expect:
            () => [
              const BondListState.loading(),
              BondListState.loaded(
                allBonds: mockBonds,
                filteredBonds: mockBonds,
                searchQuery: '',
              ),
            ],
        verify: (_) {
          verify(mockRepository.getBonds()).called(1);
        },
      );

      blocTest<BondListCubit, BondListState>(
        'emits [loading, error] when fetchBonds fails',
        build: () {
          when(
            mockRepository.getBonds(),
          ).thenThrow(Exception('Failed to load bonds'));
          return bondListCubit;
        },
        act: (cubit) => cubit.fetchBonds(),
        expect:
            () => [
              const BondListState.loading(),
              const BondListState.error('Exception: Failed to load bonds'),
            ],
        verify: (_) {
          verify(mockRepository.getBonds()).called(1);
        },
      );
    });

    group('search', () {
      final mockBonds = [
        const BondSummary(
          logo: 'https://example.com/logo1.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Apple Inc',
          tags: ['Technology', 'Growth'],
        ),
        const BondSummary(
          logo: 'https://example.com/logo2.png',
          isin: 'INE456B01023',
          rating: 'AA+',
          companyName: 'Microsoft Corp',
          tags: ['Technology', 'Stable'],
        ),
        const BondSummary(
          logo: 'https://example.com/logo3.png',
          isin: 'INE789C01034',
          rating: 'A+',
          companyName: 'Banking Solutions Ltd',
          tags: ['Finance', 'Banking'],
        ),
      ];

      blocTest<BondListCubit, BondListState>(
        'filters bonds by company name',
        build: () => bondListCubit,
        seed:
            () => BondListState.loaded(
              allBonds: mockBonds,
              filteredBonds: mockBonds,
              searchQuery: '',
            ),
        act: (cubit) => cubit.search('Apple'),
        expect:
            () => [
              BondListState.loaded(
                allBonds: mockBonds,
                filteredBonds: [mockBonds[0]], // Only Apple Inc
                searchQuery: 'Apple',
              ),
            ],
      );

      blocTest<BondListCubit, BondListState>(
        'filters bonds by ISIN',
        build: () => bondListCubit,
        seed:
            () => BondListState.loaded(
              allBonds: mockBonds,
              filteredBonds: mockBonds,
              searchQuery: '',
            ),
        act: (cubit) => cubit.search('INE456B01023'),
        expect:
            () => [
              BondListState.loaded(
                allBonds: mockBonds,
                filteredBonds: [mockBonds[1]], // Only Microsoft Corp
                searchQuery: 'INE456B01023',
              ),
            ],
      );

      blocTest<BondListCubit, BondListState>(
        'filters bonds by tags',
        build: () => bondListCubit,
        seed:
            () => BondListState.loaded(
              allBonds: mockBonds,
              filteredBonds: mockBonds,
              searchQuery: '',
            ),
        act: (cubit) => cubit.search('Technology'),
        expect:
            () => [
              BondListState.loaded(
                allBonds: mockBonds,
                filteredBonds: [
                  mockBonds[0],
                  mockBonds[1],
                ], // Apple and Microsoft
                searchQuery: 'Technology',
              ),
            ],
      );

      blocTest<BondListCubit, BondListState>(
        'returns all bonds when search query is empty',
        build: () => bondListCubit,
        seed:
            () => BondListState.loaded(
              allBonds: mockBonds,
              filteredBonds: [mockBonds[0]], // Previously filtered
              searchQuery: 'Apple',
            ),
        act: (cubit) => cubit.search(''),
        expect:
            () => [
              BondListState.loaded(
                allBonds: mockBonds,
                filteredBonds: mockBonds, // All bonds restored
                searchQuery: '',
              ),
            ],
      );

      blocTest<BondListCubit, BondListState>(
        'search is case insensitive',
        build: () => bondListCubit,
        seed:
            () => BondListState.loaded(
              allBonds: mockBonds,
              filteredBonds: mockBonds,
              searchQuery: '',
            ),
        act: (cubit) => cubit.search('apple'),
        expect:
            () => [
              BondListState.loaded(
                allBonds: mockBonds,
                filteredBonds: [mockBonds[0]], // Apple Inc found with lowercase
                searchQuery: 'apple',
              ),
            ],
      );

      blocTest<BondListCubit, BondListState>(
        'returns empty list when no matches found',
        build: () => bondListCubit,
        seed:
            () => BondListState.loaded(
              allBonds: mockBonds,
              filteredBonds: mockBonds,
              searchQuery: '',
            ),
        act: (cubit) => cubit.search('NonExistentCompany'),
        expect:
            () => [
              BondListState.loaded(
                allBonds: mockBonds,
                filteredBonds: [], // No matches
                searchQuery: 'NonExistentCompany',
              ),
            ],
      );

      test('does nothing when state is not loaded', () {
        // Start with initial state
        bondListCubit.search('Apple');
        expect(bondListCubit.state, equals(const BondListState.initial()));
      });
    });

    group('clearSearch', () {
      final mockBonds = [
        const BondSummary(
          logo: 'https://example.com/logo1.png',
          isin: 'INE123A01012',
          rating: 'AAA',
          companyName: 'Apple Inc',
          tags: ['Technology'],
        ),
      ];

      blocTest<BondListCubit, BondListState>(
        'clears search and shows all bonds',
        build: () => bondListCubit,
        seed:
            () => BondListState.loaded(
              allBonds: mockBonds,
              filteredBonds: [], // Previously filtered to empty
              searchQuery: 'NonExistent',
            ),
        act: (cubit) => cubit.clearSearch(),
        expect:
            () => [
              BondListState.loaded(
                allBonds: mockBonds,
                filteredBonds: mockBonds, // All bonds restored
                searchQuery: '',
              ),
            ],
      );

      test('does nothing when state is not loaded', () {
        bondListCubit.clearSearch();
        expect(bondListCubit.state, equals(const BondListState.initial()));
      });
    });
  });
}
