// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/repository/bond_repository.dart' as _i209;
import '../../presentation/cubit/bond_detail_cubit.dart' as _i229;
import '../../presentation/cubit/bond_list_cubit.dart' as _i875;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i209.BondRepository>(
      () => _i209.BondRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i229.BondDetailCubit>(
      () => _i229.BondDetailCubit(gh<_i209.BondRepository>()),
    );
    gh.factory<_i875.BondListCubit>(
      () => _i875.BondListCubit(gh<_i209.BondRepository>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i464.NetworkModule {}
