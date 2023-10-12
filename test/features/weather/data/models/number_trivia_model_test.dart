import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_app_homebase/features/weather/data/models/number_trivia_model.dart';
import 'package:flutter_weather_app_homebase/features/weather/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tNumberTriviaModel = NumberTriviaModel(text: "Test text", number: 1);

  test('should be a subclass of NumberTrivia entity', () async {
    // assert
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group("fromJson", () {
    test("should return a valid model when the JSON number is an integer",
        () async {
      // sample model
      const tNumberTriviaModel = NumberTriviaModel(
          text:
              "418 is the error code for \"I'm a teapot\" in the Hyper Text Coffee Pot Control Protocol.",
          number: 418);

      // arrange
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));

      // act
      final result = NumberTriviaModel.fromJson(jsonMap);

      //assert
      expect(result, tNumberTriviaModel);
    });
    test("should return valid model when the JSON is regarded as a double",
        () async {
      //sample model
      const tNumberTriviaModel = NumberTriviaModel(
          text:
              "1.0 is the number of planck volumes in the observable universe.",
          number: 1);

      // arrange
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('trivia_double.json'));

      // act
      final result = NumberTriviaModel.fromJson(jsonMap);

      //assert
      expect(result, tNumberTriviaModel);
    });
  });

  group("toJson", () {
    test("should return a JSON map containing the proper data", () async {
      // sample model
      const tNumberTriviaModel =
          NumberTriviaModel(text: "Test Text", number: 1);

      //act
      final result = tNumberTriviaModel.toJson();
      // assert
      final expectedJsonMap = {"text": "Test Text", "number": 1};

      expect(result, expectedJsonMap);
    });
  });
}
