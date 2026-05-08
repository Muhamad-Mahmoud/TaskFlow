import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final List<String>? errors;

  const ServerFailure(super.message, {this.errors});

  @override
  List<Object?> get props => [message, errors];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

