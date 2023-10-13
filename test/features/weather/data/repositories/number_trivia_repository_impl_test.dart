import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_app_homebase/core/error/exception.dart';
import 'package:flutter_weather_app_homebase/core/error/failures.dart';
import 'package:flutter_weather_app_homebase/core/network/network_info.dart';
import 'package:flutter_weather_app_homebase/features/weather/data/data_sources/number_trivia_local_data_source.dart';
import 'package:flutter_weather_app_homebase/features/weather/data/data_sources/number_trivia_remote_data_source.dart';
import 'package:flutter_weather_app_homebase/features/weather/data/models/number_trivia_model.dart';
import 'package:flutter_weather_app_homebase/features/weather/data/repositories/number_trivia_repository_impl.dart';
import 'package:flutter_weather_app_homebase/features/weather/domain/entities/number_trivia.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<NumberTriviaRemoteDataSource>(),
  MockSpec<NumberTriviaLocalDataSource>(),
  MockSpec<NetworkInfo>(),
])
void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNumberTriviaRemoteDataSource remoteDataSource;
  late MockNumberTriviaLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;

  setUp(() {
    remoteDataSource = MockNumberTriviaRemoteDataSource();
    localDataSource = MockNumberTriviaLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
        networkInfo: networkInfo);
  });

  const tNumber = 1;
  const tNumberTriviaModel =
      NumberTriviaModel(text: "test trivia", number: tNumber);
  const NumberTrivia tNumberTrivia = tNumberTriviaModel;

  void runTestsOnline(Function body) {
    group("device is online", () {
      setUp(() {
        when(networkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group("device is offline", () {
      setUp(() {
        when(networkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    // DATA FOR THE MOCKS AND ASSERTIONS
    // We'll use these three variables throughout all the tests

    runTestsOnline(() {
      test(
          "should return remote data when the call to remote data source is successful",
          () async {
        // arrange
        when(remoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(remoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test(
          "should cache data locally when the call to remote data source is successful",
          () async {
        // arrange
        when(remoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(remoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(localDataSource
            .cacheNumberTrivia(tNumberTrivia as NumberTriviaModel));
      });

      test(
          "should return server failure when the call to remote data source is unsuccessful",
          () async {
        // arrange remoteDataSource throw Exception when call getConcreteNumberTrivia()
        when(remoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenThrow(ServerException());

        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        // assert
        verify(remoteDataSource.getConcreteNumberTrivia(tNumber));
        // verify any functions of localDataSource is not used so nothing should be cached locally
        verifyZeroInteractions(localDataSource);
        expect(result, equals(const Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test(
          "should return last locally cached data when the cached data is present",
          () async {
        // arrange
        when(localDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verifyZeroInteractions(remoteDataSource);
        verify(localDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test("should return CacheFailure when there is no cached data present",
          () async {
        // arrange
        when(localDataSource.getLastNumberTrivia()).thenThrow(CacheException());

        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        // assert
        verifyZeroInteractions(remoteDataSource);
        verify(localDataSource.getLastNumberTrivia());
        expect(result, equals(const Left(CacheFailure())));
      });
    });
  });

  group("getRandomTrivia", () {
    runTestsOnline(() {
      test(
          "should return remote data when the call to remote data source is successful",
          () async {
        // arrange
        when(remoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verify(remoteDataSource.getRandomNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test(
          "should cache data locally when the call to remote data source is successful",
          () async {
        // arrange
        when(remoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        await repository.getRandomNumberTrivia();
        // assert
        verify(remoteDataSource.getRandomNumberTrivia());
        verify(localDataSource
            .cacheNumberTrivia(tNumberTrivia as NumberTriviaModel));
      });

      test(
          "should return server failure when the call to remote data source is unsuccessful",
          () async {
        // arrange remoteDataSource throw Exception when call getConcreteNumberTrivia()
        when(remoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());

        // act
        final result = await repository.getRandomNumberTrivia();

        // assert
        verify(remoteDataSource.getRandomNumberTrivia());
        // verify any functions of localDataSource is not used so nothing should be cached locally
        verifyZeroInteractions(localDataSource);
        expect(result, equals(const Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test(
          "should return last locally cached data when the cached data is present",
          () async {
        // arrange
        when(localDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verifyZeroInteractions(remoteDataSource);
        verify(localDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test("should return CacheFailure when there is no cached data present",
          () async {
        // arrange
        when(localDataSource.getLastNumberTrivia()).thenThrow(CacheException());

        // act
        final result = await repository.getRandomNumberTrivia();

        // assert
        verifyZeroInteractions(remoteDataSource);
        verify(localDataSource.getLastNumberTrivia());
        expect(result, equals(const Left(CacheFailure())));
      });
    });
  });
}
