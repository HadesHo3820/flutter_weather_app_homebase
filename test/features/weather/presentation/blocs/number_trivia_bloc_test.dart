import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_app_homebase/core/error/failures.dart';
import 'package:flutter_weather_app_homebase/core/usecases/usecase.dart';
import 'package:flutter_weather_app_homebase/core/util/input_converter.dart';
import 'package:flutter_weather_app_homebase/features/weather/domain/entities/number_trivia.dart';
import 'package:flutter_weather_app_homebase/features/weather/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_weather_app_homebase/features/weather/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_weather_app_homebase/features/weather/presentation/blocs/number_trivia_bloc/number_trivia_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GetConcreteNumberTrivia>(),
  MockSpec<GetRandomNumberTrivia>(),
  MockSpec<InputConverter>()
])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
        concrete: mockGetConcreteNumberTrivia,
        random: mockGetRandomNumberTrivia,
        converter: mockInputConverter);
  });

  test("initialState should be Empty", () {
    // assert
    expect(bloc.state, equals(Empty()));
  });

  group("GetTriviaForConcreteNumber", () {
    const tNumberString = "1";
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: "test trivia", number: 1);

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(const Right(tNumberParsed));

    void setUpMockGetConcreteSuccess() => when(mockGetConcreteNumberTrivia(any))
        .thenAnswer((_) async => const Right(tNumberTrivia));

    void setUpMockGetConcreteServerOrCacheFailure(Failure failure) =>
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(failure));

    blocTest(
      "should call the InputConverter to validate and convert the string to an unsigned integer",
      setUp: () {
        setUpMockInputConverterSuccess();
      },
      build: () => bloc,
      act: (bloc) async {
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
      verify: (_) {
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    blocTest(
      'should emit [Error] when the input is invalid',
      build: () {
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [const Error(message: INVALID_INPUT_FAILURE_MESSAGE)],
    );

    blocTest(
      "should get data from the concrete use case",
      setUp: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteSuccess();
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      build: () => bloc,
      verify: (_) {
        verify(
            mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
      },
    );

    blocTest(
      "should emit [Loading, Loaded] when data is gotten successfully",
      setUp: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteSuccess();
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      build: () => bloc,
      expect: () => [Loading(), const Loaded(trivia: tNumberTrivia)],
    );

    blocTest(
      "should emit [Loading, Error] when getting data fails from Server",
      setUp: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteServerOrCacheFailure(const ServerFailure());
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      build: () => bloc,
      expect: () => [Loading(), const Error(message: SERVER_FAILURE_MESSAGE)],
    );

    blocTest(
      "should emit [Loading, Error] with getting data fails from Local Cache",
      setUp: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteServerOrCacheFailure(const CacheFailure());
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      build: () => bloc,
      expect: () => [Loading(), const Error(message: CACHE_FAILURE_MESSAGE)],
    );
  });

  group("GetTriviaForRandomNumber", () {
    const tNumberTrivia = NumberTrivia(text: "test trivia", number: 1);

    void setUpMockGetRandomSuccess() =>
        when(mockGetRandomNumberTrivia(NoParams()))
            .thenAnswer((_) async => const Right(tNumberTrivia));

    void setUpMockGetConcreteServerOrCacheFailure(Failure failure) =>
        when(mockGetRandomNumberTrivia(NoParams()))
            .thenAnswer((_) async => Left(failure));

    blocTest(
      "should get data from the random use case",
      setUp: () {
        setUpMockGetRandomSuccess();
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      build: () => bloc,
      verify: (_) {
        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    blocTest(
      "should emit [Loading, Loaded] when data is gotten successfully",
      setUp: () {
        setUpMockGetRandomSuccess();
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      build: () => bloc,
      expect: () => [Loading(), const Loaded(trivia: tNumberTrivia)],
    );

    blocTest(
      "should emit [Loading, Error] when getting data fails from Server",
      setUp: () {
        setUpMockGetConcreteServerOrCacheFailure(const ServerFailure());
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      build: () => bloc,
      expect: () => [Loading(), const Error(message: SERVER_FAILURE_MESSAGE)],
    );

    blocTest(
      "should emit [Loading, Error] with getting data fails from Local Cache",
      setUp: () {
        setUpMockGetConcreteServerOrCacheFailure(const CacheFailure());
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      build: () => bloc,
      expect: () => [Loading(), const Error(message: CACHE_FAILURE_MESSAGE)],
    );
  });
}
