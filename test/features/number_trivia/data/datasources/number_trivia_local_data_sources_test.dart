import 'dart:convert';

import 'package:flutter_number_trivia/core/error/exceptions.dart';
import 'package:flutter_number_trivia/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:flutter_number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockedSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  MockedSharedPreferences mockedSharedPreferences;
  NumberTriviaLocalSharedPrefDataSource dataSource;

  setUp(() {
    mockedSharedPreferences = MockedSharedPreferences();
    dataSource = NumberTriviaLocalSharedPrefDataSource(
        sharedPreferences: mockedSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));
    test(
        'should return NumberTrivia from SharedPreferences where is one in the cache',
        () async {
      // arrange
      when(mockedSharedPreferences.getString(any))
          .thenReturn(fixture('trivia_cached.json'));
      // act
      final result = await dataSource.getLastNumberTrivia();
      // assert
      verify(mockedSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw CacheException where there is no cached value',
        () async {
      // arrange
      when(mockedSharedPreferences.getString(any)).thenReturn(null);
      // act
      final call = dataSource.getLastNumberTrivia;
      // assert
      expect(() => call(), throwsA(isInstanceOf<CacheException>()));
    });
  });
  group('cacheNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'test trivia');
    test(
      'should call SharedPreferences to cache the data',
      () async {
        // act
        dataSource.cacheNumberTrivia(tNumberTriviaModel);
        // assert
        final expectedJsonString = jsonEncode(tNumberTriviaModel.toJson());
        verify(mockedSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA,
          expectedJsonString,
        ));
      },
    );
  });
}
