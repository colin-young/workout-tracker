import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';

part 'global_providers.g.dart';

@riverpod
Database database(DatabaseRef ref) {
  throw Exception('Database not initialized');
}

// TODO add schema version to all repos to allow evolving/upgrading schema