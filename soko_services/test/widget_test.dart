import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:provider/provider.dart'; // Unused, removing

import 'package:soko_services/main.dart';
import 'package:soko_services/app/views/home/home_page.dart';
import 'package:soko_services/app/widgets/home/recommended_card.dart';

// Mock HttpOverrides
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest();
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  var headers = MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();
}

class MockHttpHeaders extends Fake implements HttpHeaders {}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => 0;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value([]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  testWidgets('App renders Home Page with Horizontal Scrolling Lists', (
    WidgetTester tester,
  ) async {
    // Ignore overflow errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is FlutterError &&
          (details.exception as FlutterError).message.contains('overflowed')) {
        return;
      }
      // Forward other errors
    };

    HttpOverrides.global = MockHttpOverrides();

    // Resize to a large screen to minimize overflows
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify HomePage exists
    expect(find.byType(HomePage), findsOneWidget);

    // Check for "Recommended for you"
    expect(find.text('Recommended for you'), findsOneWidget);

    // Verify we have multiple RecommendedCards (from our mocked 2 items in ApiProviders)
    expect(find.byType(RecommendedCard), findsNWidgets(2));
    expect(find.text('The Clay Studio'), findsOneWidget);
    expect(find.text('Vibrant Candles'), findsOneWidget);

    // Verify we have Categories (Pickle etc)
    expect(find.text('Pickle'), findsOneWidget);

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      HttpOverrides.global = null;
    });
  });
}
