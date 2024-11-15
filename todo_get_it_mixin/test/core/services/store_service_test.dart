import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_get_it_signals/features/core/services/store_service.dart';

import 'store_service_test.mocks.dart';

@GenerateMocks([Box])
void main() {
  late StoreService storeService;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    storeService = StoreService(mockBox);
  });

  group('save', () {
    const tKey = 'key';
    const tValue = {"title": "Title"};

    test(
      'should jsonEncode the value while saving it in the store',
      () async {
        // arrange
        when(mockBox.put(any, any)).thenAnswer((_) async => {});

        // act
        await storeService.save(tKey, tValue);

        // assert
        final encodedValue = jsonEncode(tValue);
        verify(mockBox.put(tKey, encodedValue));
      },
    );

    test(
      'should throw an exception if the store throws an exception',
      () async {
        // arrange
        when(mockBox.put(any, any)).thenThrow(Exception());

        // act
        final call = storeService.save;

        // assert
        expect(() => call(tKey, tValue), throwsException);
      },
    );
  });

  group('get', () {
    const tKey = 'key';
    const tValue = '{"title": "Title"}';

    test(
      'should jsonDecode the value while getting it from the store',
      () async {
        // arrange
        when(mockBox.get(any)).thenReturn(tValue);

        // act
        final result = storeService.get(tKey);

        // assert
        final decodedValue = jsonDecode(tValue);
        expect(result, decodedValue);
      },
    );

    test(
      'should return null if the store returns null',
      () async {
        // arrange
        when(mockBox.get(any)).thenReturn(null);

        // act
        final result = storeService.get(tKey);

        // assert
        expect(result, null);
      },
    );

    test(
      'should throw an exception if the store throws an exception',
      () async {
        // arrange
        when(mockBox.get(any)).thenThrow(Exception());

        // act
        final call = storeService.get;

        // assert
        expect(() => call(tKey), throwsException);
      },
    );
  });
}
