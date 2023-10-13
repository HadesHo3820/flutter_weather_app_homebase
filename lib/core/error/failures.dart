import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]) : super();
}

// General Failures
class ServerFailure extends Failure {
  final String? msg;
  const ServerFailure({this.msg});
  @override
  List<Object?> get props => [msg];
}

class CacheFailure extends Failure {
  final String? msg;
  const CacheFailure({this.msg});

  @override
  List<Object?> get props => [msg];
}
