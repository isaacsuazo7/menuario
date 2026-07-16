import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The wall clock as a single overridable seam.
///
/// `TodayHeader`'s date and `cookScheduleProvider`'s weekday lookup both
/// read this instead of calling `DateTime.now()` directly, so tests fix
/// "now" via a provider override instead of faking the SDK clock.
final nowProvider = Provider<DateTime>((ref) => DateTime.now());
