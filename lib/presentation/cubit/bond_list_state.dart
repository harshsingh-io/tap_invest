import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/bond_summary_model.dart';

part 'bond_list_state.freezed.dart';

@freezed
class BondListState with _$BondListState {
  const factory BondListState.initial() = _Initial;
  const factory BondListState.loading() = _Loading;
  const factory BondListState.loaded({
    required List<BondSummary> allBonds,
    required List<BondSummary> filteredBonds,
    @Default('') String searchQuery,
  }) = _Loaded;
  const factory BondListState.error(String message) = _Error;
}
