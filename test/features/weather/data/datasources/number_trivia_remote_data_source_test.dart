import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_app_homebase/core/error/exception.dart';
import 'package:flutter_weather_app_homebase/features/weather/data/data_sources/number_trivia_remote_data_source.dart';
import 'package:flutter_weather_app_homebase/features/weather/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  late MockClient mockClient;
  late NumberTriviaRemoteDataSourceImpl numberTriviaRemoteDataSourceImpl;
  setUp(() {
    mockClient = MockClient();
    numberTriviaRemoteDataSourceImpl =
        NumberTriviaRemoteDataSourceImpl(client: mockClient);
  });

  void setUpMockHttpClientSuccess200(Function testFunction) {
    group("With ClientSuccess200 Result", () {
      setUp(() {
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));
      });

      testFunction();
    });
  }

  void setUpMockHttpClientFailure404(Function testFunction) {
    group("With ClientSuccess404 Result", () {
      // General Arrangement
      setUp(() {
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 404));
      });

      testFunction();
    });
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    setUpMockHttpClientSuccess200(() {
      test(
          "should perform a Get request on a URL with number being the endpoint and with application/json header",
          () {
        // act
        numberTriviaRemoteDataSourceImpl.getConcreteNumberTrivia(tNumber);

        // assert
        verify(mockClient.get(Uri.parse('$BASE_URL/$tNumber'),
            headers: {'Content-Type': 'application/json'}));
      });
    });

    setUpMockHttpClientSuccess200(() => test(
            'should return NumberTrivia when the response code is 200 (success)',
            () async {
          // act
          final result = await numberTriviaRemoteDataSourceImpl
              .getConcreteNumberTrivia(tNumber);

          // assert
          expect(result, equals(tNumberTriviaModel));
        }));

    setUpMockHttpClientFailure404(() => test(
            "should throw a ServerException when the response code is 404 or other",
            () async {
          // act
          final call = numberTriviaRemoteDataSourceImpl.getConcreteNumberTrivia;

          // assert
          expect(() => call(tNumber),
              throwsA(const TypeMatcher<ServerException>()));
        }));
  });

  group('getRandomTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    setUpMockHttpClientSuccess200(() {
      test(
          "should perform a Get request on a URL with *random* with application/json header",
          () {
        // act
        numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia();

        // assert
        verify(mockClient.get(Uri.parse('$BASE_URL/random'),
            headers: {'Content-Type': 'application/json'}));
      });
    });

    setUpMockHttpClientSuccess200(() => test(
            'should return NumberTrivia when the response code is 200 (success)',
            () async {
          // act
          final result =
              await numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia();

          // assert
          expect(result, equals(tNumberTriviaModel));
        }));

    setUpMockHttpClientFailure404(() => test(
            "should throw a ServerException when the response code is 404 or other",
            () async {
          // act
          final call = numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia;

          // assert
          expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
        }));
  });
}
