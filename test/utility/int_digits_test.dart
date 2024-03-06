import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/utility/int_digits.dart';

void main() {
  test('int hundreds should be correct', () {
    const value = 573;

    expect(value.hundreds(), 5);
  });

  test('int tens should be correct', () {
    const value = 573;

    expect(value.tens(), 7);
  });

  test('int ones should be correct', () {
    const value = 573;

    expect(value.ones(), 3);
  });

  test('invalid integer throws exception', () {
    const value = 1000;

    expect(() => value.hundreds(), throwsA(isA<UnsupportedError>()));
    expect(() => value.tens(), throwsA(isA<UnsupportedError>()));
    expect(() => value.ones(), throwsA(isA<UnsupportedError>()));
  });
}