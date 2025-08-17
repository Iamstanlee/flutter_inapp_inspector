import 'package:flutter_inapp_inspector/src/http/request_inspector.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRequestOptions extends Mock implements RequestOptions {}

class MockResponse extends Mock implements Response {}

class MockDioException extends Mock implements DioException {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  group('HttpRequest', () {
    test('should create an instance with required fields', () {
      final timestamp = DateTime.now();
      const method = 'GET';
      const url = 'https://example.com';

      final request = HttpRequest(
        timestamp: timestamp,
        method: method,
        url: url,
      );

      expect(request.timestamp, timestamp);
      expect(request.method, method);
      expect(request.url, url);
      expect(request.headers, null);
      expect(request.data, null);
      expect(request.statusCode, null);
      expect(request.response, null);
      expect(request.error, null);
    });

    test('should create an instance with all fields', () {
      final timestamp = DateTime.now();
      const method = 'POST';
      const url = 'https://example.com/api';
      final headers = {'Content-Type': 'application/json'};
      final data = {'key': 'value'};
      const statusCode = 200;
      final response = {'result': 'success'};
      const error = 'Some error';

      final request = HttpRequest(
        timestamp: timestamp,
        method: method,
        url: url,
        headers: headers,
        data: data,
        statusCode: statusCode,
        response: response,
        error: error,
      );

      expect(request.timestamp, timestamp);
      expect(request.method, method);
      expect(request.url, url);
      expect(request.headers, headers);
      expect(request.data, data);
      expect(request.statusCode, statusCode);
      expect(request.response, response);
      expect(request.error, error);
    });
  });

  group('RequestInspector', () {
    setUp(() {
      // Clear requests before each test
      RequestInspector.instance.clearRequests();
    });

    test('requests should be empty initially', () {
      expect(RequestInspector.instance.requests, isEmpty);
    });

    test('addRequest should add a request to the list', () {
      final request = HttpRequest(
        timestamp: DateTime.now(),
        method: 'GET',
        url: 'https://example.com',
      );

      RequestInspector.instance.addRequest(request);

      expect(RequestInspector.instance.requests.length, 1);
      expect(RequestInspector.instance.requests.first, request);
    });

    test('addRequest should add requests to the beginning of the list', () {
      final request1 = HttpRequest(
        timestamp: DateTime.now(),
        method: 'GET',
        url: 'https://example.com/1',
      );

      final request2 = HttpRequest(
        timestamp: DateTime.now(),
        method: 'GET',
        url: 'https://example.com/2',
      );

      RequestInspector.instance.addRequest(request1);
      RequestInspector.instance.addRequest(request2);

      expect(RequestInspector.instance.requests.length, 2);
      expect(RequestInspector.instance.requests.first, request2);
      expect(RequestInspector.instance.requests.last, request1);
    });

    test('clearRequests should remove all requests', () {
      final request = HttpRequest(
        timestamp: DateTime.now(),
        method: 'GET',
        url: 'https://example.com',
      );

      RequestInspector.instance.addRequest(request);
      expect(RequestInspector.instance.requests.length, 1);

      RequestInspector.instance.clearRequests();

      expect(RequestInspector.instance.requests, isEmpty);
    });

    test('requestsStream should emit the current list of requests', () async {
      final request = HttpRequest(
        timestamp: DateTime.now(),
        method: 'GET',
        url: 'https://example.com',
      );

      expectLater(
        RequestInspector.instance.requestsStream,
        emits([request]),
      );

      RequestInspector.instance.addRequest(request);
    });
  });

  group('AppInspectorInterceptor', () {
    late AppInspectorDioInterceptor interceptor;
    late MockRequestOptions mockRequestOptions;
    late MockResponse mockResponse;
    late MockDioException mockDioException;
    late MockRequestInterceptorHandler mockRequestHandler;
    late MockResponseInterceptorHandler mockResponseHandler;
    late MockErrorInterceptorHandler mockErrorHandler;

    setUpAll(() {
      registerFallbackValue(MockRequestOptions());
      registerFallbackValue(MockResponse());
    });

    setUp(() {
      interceptor = AppInspectorDioInterceptor();
      mockRequestOptions = MockRequestOptions();
      mockResponse = MockResponse();
      mockDioException = MockDioException();
      mockRequestHandler = MockRequestInterceptorHandler();
      mockResponseHandler = MockResponseInterceptorHandler();
      mockErrorHandler = MockErrorInterceptorHandler();

      // Clear requests before each test
      RequestInspector.instance.clearRequests();

      // Set up mocks
      when(() => mockRequestOptions.method).thenReturn('GET');
      when(() => mockRequestOptions.uri)
          .thenReturn(Uri.parse('https://example.com'));
      when(() => mockRequestOptions.headers).thenReturn({});
      when(() => mockRequestOptions.data).thenReturn(null);

      when(() => mockResponse.requestOptions).thenReturn(mockRequestOptions);
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn({'result': 'success'});

      when(() => mockDioException.requestOptions)
          .thenReturn(mockRequestOptions);
      when(() => mockDioException.response).thenReturn(mockResponse);

      when(() => mockRequestHandler.next(any())).thenReturn(null);
      when(() => mockResponseHandler.next(any())).thenReturn(null);
    });

    test('onRequest should store the request in the map', () {
      interceptor.onRequest(mockRequestOptions, mockRequestHandler);

      verify(() => mockRequestHandler.next(mockRequestOptions)).called(1);

      // We can't directly verify the map, but we can test the behavior
      // by calling onResponse with the same request options
      interceptor.onResponse(mockResponse, mockResponseHandler);

      expect(RequestInspector.instance.requests.length, 1);
      expect(RequestInspector.instance.requests.first.method, 'GET');
      expect(
          RequestInspector.instance.requests.first.url, 'https://example.com');
    });

    test(
        'onResponse should add the request with response to the RequestInspector',
        () {
      interceptor.onRequest(mockRequestOptions, mockRequestHandler);

      interceptor.onResponse(mockResponse, mockResponseHandler);

      verify(() => mockResponseHandler.next(mockResponse)).called(1);

      expect(RequestInspector.instance.requests.length, 1);
      expect(RequestInspector.instance.requests.first.method, 'GET');
      expect(
          RequestInspector.instance.requests.first.url, 'https://example.com');
      expect(RequestInspector.instance.requests.first.statusCode, 200);
      expect(RequestInspector.instance.requests.first.response,
          {'result': 'success'});
    });

    test('onError should add the request with error to the RequestInspector',
        () {
      interceptor.onRequest(mockRequestOptions, mockRequestHandler);

      interceptor.onError(mockDioException, mockErrorHandler);

      verify(() => mockErrorHandler.next(mockDioException)).called(1);

      expect(RequestInspector.instance.requests.length, 1);
      expect(RequestInspector.instance.requests.first.method, 'GET');
      expect(
          RequestInspector.instance.requests.first.url, 'https://example.com');
      expect(RequestInspector.instance.requests.first.statusCode, 200);
      expect(RequestInspector.instance.requests.first.response,
          {'result': 'success'});
      expect(
          RequestInspector.instance.requests.first.error, 'MockDioException');
    });
  });
}
