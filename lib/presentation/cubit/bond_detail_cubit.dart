import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repository/bond_repository.dart';
import 'bond_detail_state.dart';

@injectable
class BondDetailCubit extends Cubit<BondDetailState> {
  final BondRepository _repository;

  BondDetailCubit(this._repository) : super(const BondDetailState.initial());

  Future<void> fetchDetail(String isin) async {
    emit(const BondDetailState.loading());
    try {
      final detail = await _repository.getBondDetail(isin);
      emit(
        BondDetailState.loaded(
          detail: detail,
          chartType: FinancialChartType.ebitda,
        ),
      );
    } catch (e) {
      emit(BondDetailState.error(e.toString()));
    }
  }

  void toggleChartType(FinancialChartType type) {
    state.whenOrNull(
      loaded: (detail, chartType) {
        emit(BondDetailState.loaded(detail: detail, chartType: type));
      },
    );
  }
}
