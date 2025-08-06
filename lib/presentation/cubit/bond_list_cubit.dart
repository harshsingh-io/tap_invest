import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repository/bond_repository.dart';
import 'bond_list_state.dart';

@injectable
class BondListCubit extends Cubit<BondListState> {
  final BondRepository _repository;

  BondListCubit(this._repository) : super(const BondListState.initial());

  Future<void> fetchBonds() async {
    emit(const BondListState.loading());
    try {
      final bonds = await _repository.getBonds();
      emit(
        BondListState.loaded(
          allBonds: bonds,
          filteredBonds: bonds,
          searchQuery: '',
        ),
      );
    } catch (e) {
      emit(BondListState.error(e.toString()));
    }
  }

  void search(String query) {
    state.whenOrNull(
      loaded: (allBonds, filteredBonds, searchQuery) {
        if (query.isEmpty) {
          emit(
            BondListState.loaded(
              allBonds: allBonds,
              filteredBonds: allBonds,
              searchQuery: query,
            ),
          );
        } else {
          final filtered =
              allBonds.where((bond) {
                final queryLower = query.toLowerCase();
                return bond.companyName.toLowerCase().contains(queryLower) ||
                    bond.isin.toLowerCase().contains(queryLower) ||
                    bond.tags.any(
                      (tag) => tag.toLowerCase().contains(queryLower),
                    );
              }).toList();

          emit(
            BondListState.loaded(
              allBonds: allBonds,
              filteredBonds: filtered,
              searchQuery: query,
            ),
          );
        }
      },
    );
  }

  void clearSearch() {
    state.whenOrNull(
      loaded: (allBonds, filteredBonds, searchQuery) {
        emit(
          BondListState.loaded(
            allBonds: allBonds,
            filteredBonds: allBonds,
            searchQuery: '',
          ),
        );
      },
    );
  }
}
