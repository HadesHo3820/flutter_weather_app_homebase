import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_weather_app_homebase/core/error/failures.dart';
import 'package:flutter_weather_app_homebase/core/usecases/usecase.dart';
import 'package:flutter_weather_app_homebase/features/weather/domain/entities/number_trivia.dart';
import 'package:flutter_weather_app_homebase/features/weather/domain/repositories/number_trivia_repository.dart';

class GetConcreteNumberTrivia extends UseCase<NumberTrivia, Params> {
  final NumberTriviaRepository repository;

  GetConcreteNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(Params params) async {
    return await repository.getConcreteNumberTrivia(params.number);
  }

  // Future<Either<Failure, NumberTrivia>> call({required int number}) async {
  //   return await repository.getConcreteNumberTrivia(number);
  // }
}

class Params extends Equatable {
  final int number;
  const Params({required this.number});

  @override
  List<Object?> get props => [number];
}
