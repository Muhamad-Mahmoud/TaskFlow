import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
	final bool succeeded;
	final String? message;
	final List<String>? errors;
	final T? data;

	const ApiResponse({required this.succeeded, this.message, this.errors, this.data});

	factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
			_$ApiResponseFromJson(json, fromJsonT);
}

@JsonSerializable(genericArgumentFactories: true)
class PagedResult<T> {
	final List<T> items;
	final int pageNumber;
	final int pageSize;
	final int totalPages;
	final int totalCount;
	final bool hasPreviousPage;
	final bool hasNextPage;
	final int page;

	const PagedResult({
		required this.items, required this.pageNumber, required this.pageSize,
		required this.totalPages, required this.totalCount,
		required this.hasPreviousPage, required this.hasNextPage, required this.page,
	});

	factory PagedResult.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
			_$PagedResultFromJson(json, fromJsonT);
}

