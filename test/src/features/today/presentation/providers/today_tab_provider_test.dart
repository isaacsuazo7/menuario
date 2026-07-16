import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/today/presentation/providers/today_tab_provider.dart';

void main() {
  test('defaults to TodayTab.cocinar', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(todayTabProvider), TodayTab.cocinar);
  });

  test('.set(TodayTab.comer) switches the state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(todayTabProvider.notifier).set(TodayTab.comer);

    expect(container.read(todayTabProvider), TodayTab.comer);
  });
}
