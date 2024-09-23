@TestOn('vm')
library flutter_test;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter/src/integrations/native_sdk_integration.dart';

import '../mocks.dart';
import '../mocks.mocks.dart';

void main() {
  group(NativeSdkIntegration, () {
    const _channel = MethodChannel('sentry_flutter');

    TestWidgetsFlutterBinding.ensureInitialized();

    late Fixture fixture;

    setUp(() {
      fixture = Fixture();
    });

    tearDown(() {
      // ignore: deprecated_member_use
      _channel.setMockMethodCallHandler(null);
    });

    test('adds integration', () async {
      // ignore: deprecated_member_use
      _channel.setMockMethodCallHandler((MethodCall methodCall) async {});
      final mock = TestMockSentryNative();
      final integration = NativeSdkIntegration(mock);

      await integration(fixture.hub, fixture.options);

      expect(
          fixture.options.sdk.integrations, contains('nativeSdkIntegration'));
      expect(mock.numberOfInitCalls, 1);
    });

    test('does not throw', () async {
      fixture.options.automatedTestMode = false;

      fixture.sut = NativeSdkIntegration(_ThrowingMockSentryNative());
      await fixture.registerIntegration();
      expect(fixture.options.sdk.integrations.contains('nativeSdkIntegration'),
          false);
    });

    test('rethrows in tests', () async {
      fixture.sut = NativeSdkIntegration(_ThrowingMockSentryNative());
      expect(fixture.registerIntegration, throwsException);
      expect(fixture.options.sdk.integrations.contains('nativeSdkIntegration'),
          false);
    });

    test('closes native SDK', () async {
      final mock = TestMockSentryNative();
      final integration = NativeSdkIntegration(mock);

      await integration.call(fixture.hub, fixture.options);
      await integration.close();

      expect(mock.numberOfCloseCalls, 1);
    });

    test('does not call native sdk when auto init disabled', () async {
      final mock = TestMockSentryNative();
      final integration = NativeSdkIntegration(mock);
      fixture.options.autoInitializeNativeSdk = false;

      await integration.call(fixture.hub, fixture.options);

      expect(mock.numberOfInitCalls, 0);
    });

    test('does not close native when auto init disabled', () async {
      final mock = TestMockSentryNative();
      final integration = NativeSdkIntegration(mock);
      fixture.options.autoInitializeNativeSdk = false;

      await integration(fixture.hub, fixture.options);
      await integration.close();

      expect(mock.numberOfCloseCalls, 0);
    });

    test('is not added in case of an exception', () async {
      fixture.sut = NativeSdkIntegration(_ThrowingMockSentryNative());
      expect(fixture.registerIntegration, throwsException);
      expect(fixture.options.sdk.integrations, <String>[]);
    });
  });
}

class Fixture {
  final hub = MockHub();
  final options = SentryFlutterOptions(dsn: fakeDsn);
}

class _ThrowingMockSentryNative extends TestMockSentryNative {
  @override
  Future<void> init(Hub? hub) async {
    throw Exception();
  }
}
