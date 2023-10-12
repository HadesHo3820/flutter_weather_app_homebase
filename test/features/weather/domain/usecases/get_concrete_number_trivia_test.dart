import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_app_homebase/features/weather/domain/entities/number_trivia.dart';
import 'package:flutter_weather_app_homebase/features/weather/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_weather_app_homebase/features/weather/domain/usecases/get_concrete_number_trivia.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<NumberTriviaRepository>()])
// import generated mock classes
import 'get_concrete_number_trivia_test.mocks.dart';

void main() {
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });

  const tNumber = 1;
  const tNumberTrivia = NumberTrivia(text: "test", number: 1);

  test('should get trivia for the number from the repository', () async {
    /// "On the fly" implementation of the Repository using the Mockito package.
    /// When getConcreteNumberTrivia is called with any argument, always answer with
    /// the Right "side" of Either containing a test NumberTrivia object.
    when(mockNumberTriviaRepository.getConcreteNumberTrivia(any))
        .thenAnswer((_) async => const Right(tNumberTrivia));

    final result = await usecase(const Params(number: tNumber));

    // UseCase should simply return whatever was returned from the Repository
    expect(result, const Right(tNumberTrivia));

    // Verify that the method has been called on the Repository
    verify(mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber));

    // Only the above method should be called and nothing more.
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
