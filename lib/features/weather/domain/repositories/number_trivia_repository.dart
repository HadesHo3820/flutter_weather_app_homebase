import 'package:dartz/dartz.dart';
import 'package:flutter_weather_app_homebase/core/error/failures.dart';
import 'package:flutter_weather_app_homebase/features/weather/domain/entities/number_trivia.dart';

abstract class NumberTriviaRepository {
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number);
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia();
}
