import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'set_entry.freezed.dart';
part 'set_entry.g.dart';

@freezed
abstract class SetEntry with _$SetEntry {
  const factory SetEntry({
    @Default(-1) int id,
    required int reps,
    required int weight,
    required String units,
    required DateTime finishedAt,
  }) = _SetEntry;

  factory SetEntry.fromJson(Map<String, dynamic> json) =>
      _$SetEntryFromJson(json);
}
