import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/bond_detail_model.dart';
import '../models/bond_summary_model.dart';

abstract class BondRepository {
  Future<List<BondSummary>> getBonds();
  Future<BondDetail> getBondDetail(String isin);
}

@LazySingleton(as: BondRepository)
class BondRepositoryImpl implements BondRepository {
  final Dio _dio;

  BondRepositoryImpl(this._dio);

  @override
  Future<List<BondSummary>> getBonds() async {
    try {
      final response = await _dio.get(
        'https://eol122duf9sy4de.m.pipedream.net',
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => BondSummary.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load bonds: $e');
    }
  }

  @override
  Future<BondDetail> getBondDetail(String isin) async {
    try {
      final response = await _dio.get(
        'https://eo61q3zd4heiwke.m.pipedream.net',
      );
      return BondDetail.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load bond detail: $e');
    }
  }
}
