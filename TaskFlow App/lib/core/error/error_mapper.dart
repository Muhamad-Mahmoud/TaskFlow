import 'dart:developer';
import 'package:dio/dio.dart';
import 'failure.dart';

class ErrorMapper {
	static Failure fromDio(DioException e) {
    // Log the error for debugging
    log('DioError [${e.type}]: ${e.message}');
    if (e.response != null) {
      log('Response Status: ${e.response?.statusCode}');
      log('Response Data: ${e.response?.data}');
    }

		final data = e.response?.data;
		if (data is Map<String, dynamic>) {
      // Handle both camelCase and PascalCase
			final succeeded = (data['succeeded'] ?? data['Succeeded']) == true;
			final msg = (data['message'] ?? data['Message']) as String?;
			final errs = (data['errors'] ?? data['Errors']) as List?;
      
			if (!succeeded) {
        return ServerFailure(
          msg ?? 'Request failed', 
          errors: errs?.map((e) => e.toString()).toList(),
        );
      }
		} else if (data is String && data.isNotEmpty) {
      return ServerFailure(data);
    }

		switch (e.type) {
			case DioExceptionType.connectionTimeout:
			case DioExceptionType.receiveTimeout:
				return const NetworkFailure('Connection timed out');
			case DioExceptionType.connectionError:
				return ServerFailure('Connection Error: ${e.message ?? "Check API Status"}');
			case DioExceptionType.badResponse:
        return ServerFailure('Server Error (${e.response?.statusCode}): ${e.message ?? "Invalid Response"}');
			default:
				return ServerFailure(e.message ?? 'Unexpected error occurred');
		}
	}
}

