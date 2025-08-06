import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/bond_detail_model.dart';

part 'bond_detail_state.freezed.dart';

enum FinancialChartType { ebitda, revenue }

@freezed
class BondDetailState with _$BondDetailState {
  const factory BondDetailState.initial() = _Initial;
  const factory BondDetailState.loading() = _Loading;
  const factory BondDetailState.loaded({
    required BondDetail detail,
    @Default(FinancialChartType.ebitda) FinancialChartType chartType,
  }) = _Loaded;
  const factory BondDetailState.error(String message) = _Error;
}
