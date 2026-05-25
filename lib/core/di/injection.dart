// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // Menggunakan penamaan standar modern dari generator
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();