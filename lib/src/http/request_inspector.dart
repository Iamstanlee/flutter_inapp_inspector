import 'dart:async';

import 'package:dio/dio.dart';

class HttpRequest {
  final DateTime timestamp;
  final String method;
  final String url;
  final Map<String, dynamic>? headers;
  final dynamic data;
  final int? statusCode;
  final dynamic response;
  final dynamic error;
  final int? startTime;
  final int? endTime;

  HttpRequest({
    required this.timestamp,
    required this.method,
    required this.url,
    this.startTime,
    this.endTime,
    this.headers,
    this.data,
    this.statusCode,
    this.response,
    this.error,
  });
}

/// The RequestInspector class is responsible for intercepting and storing HTTP requests.
class RequestInspector {
  static final RequestInspector instance = RequestInspector._internal();

  RequestInspector._internal();

  final List<HttpRequest> _requests = [];
  final StreamController<List<HttpRequest>> _requestsStreamController =
      StreamController<List<HttpRequest>>.broadcast();

  Stream<List<HttpRequest>> get requestsStream =>
      _requestsStreamController.stream;

  List<HttpRequest> get requests => List.unmodifiable(_requests);

  void addRequest(HttpRequest request) {
    _requests.insert(
        0, request); // Add to the beginning of the list (most recent first)
    _requestsStreamController.add(_requests);
  }

  void clearRequests() {
    _requests.clear();
    _requestsStreamController.add(_requests);
  }
}

class AppInspectorDioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final startTime = DateTime.now();
    final request = HttpRequest(
      timestamp: startTime,
      method: options.method,
      url: options.uri.toString(),
      headers: options.headers,
      data: options.data,
      startTime: startTime.millisecondsSinceEpoch,
    );

    // Store the request in a map so we can update it with the response later
    _requestMap[options.hashCode] = request;

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final request = _requestMap[response.requestOptions.hashCode];
    if (request != null) {
      final updatedRequest = HttpRequest(
        timestamp: request.timestamp,
        method: request.method,
        url: request.url,
        headers: request.headers,
        data: request.data,
        statusCode: response.statusCode,
        response: response.data,
        startTime: request.startTime,
        endTime: DateTime.now().millisecondsSinceEpoch,
      );

      RequestInspector.instance.addRequest(updatedRequest);
      _requestMap.remove(response.requestOptions.hashCode);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = _requestMap[err.requestOptions.hashCode];
    if (request != null) {
      final updatedRequest = HttpRequest(
        timestamp: request.timestamp,
        method: request.method,
        url: request.url,
        headers: request.headers,
        data: request.data,
        statusCode: err.response?.statusCode,
        response: err.response?.data,
        error: err.toString(),
        startTime: request.startTime,
        endTime: DateTime.now().millisecondsSinceEpoch,
      );

      RequestInspector.instance.addRequest(updatedRequest);
      _requestMap.remove(err.requestOptions.hashCode);
    }

    handler.next(err);
  }

  // A map to store requests by their hash code so we can update them with the response
  final Map<int, HttpRequest> _requestMap = {};
}
