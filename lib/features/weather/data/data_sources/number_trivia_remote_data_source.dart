import 'dart:convert';

import 'package:flutter_weather_app_homebase/core/error/exception.dart';
import 'package:flutter_weather_app_homebase/features/weather/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

const String BASE_URL = "http://numbersapi.com";

abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint
  ///
  /// Throws a [ServerException] for all error codes
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// Calls the http://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});
  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    return _getTriviaFromUrl('$BASE_URL/$number');
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() {
    return _getTriviaFromUrl('$BASE_URL/random');
  }

  Future<NumberTriviaModel> _getTriviaFromUrl(String url) async {
    final response = await client
        .get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
