// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasources/auth_remote_datasource.dart' as _i1016;
import '../../data/datasources/storage_remote_datasource.dart' as _i24;
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../data/repositories/booking_repository_impl.dart' as _i743;
import '../../domain/repositories/auth_repository.dart' as _i1073;
import '../../domain/repositories/booking_repository.dart' as _i377;
import '../../presentation/features/auth/cubit/auth_cubit.dart' as _i224;
import '../../presentation/features/booking/cubit/booking_cubit.dart' as _i273;
import '../../presentation/features/history/cubit/car_history_cubit.dart'
    as _i252;
import 'firebase_module.dart' as _i616;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i457.FirebaseStorage>(
        () => firebaseModule.firebaseStorage);
    gh.lazySingleton<_i24.StorageRemoteDataSource>(
        () => _i24.StorageRemoteDataSourceImpl());
    gh.lazySingleton<_i1016.AuthRemoteDataSource>(
        () => _i1016.AuthRemoteDataSourceImpl(
              gh<_i59.FirebaseAuth>(),
              gh<_i974.FirebaseFirestore>(),
            ));
    gh.lazySingleton<_i1073.AuthRepository>(
        () => _i895.AuthRepositoryImpl(gh<_i1016.AuthRemoteDataSource>()));
    gh.factory<_i224.AuthCubit>(
        () => _i224.AuthCubit(gh<_i1073.AuthRepository>()));
    gh.lazySingleton<_i377.BookingRepository>(() => _i743.BookingRepositoryImpl(
          gh<_i974.FirebaseFirestore>(),
          gh<_i24.StorageRemoteDataSource>(),
        ));
    gh.factory<_i273.BookingCubit>(
        () => _i273.BookingCubit(gh<_i377.BookingRepository>()));
    gh.factory<_i252.CarHistoryCubit>(
        () => _i252.CarHistoryCubit(gh<_i377.BookingRepository>()));
    return this;
  }
}

class _$FirebaseModule extends _i616.FirebaseModule {}
