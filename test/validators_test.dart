import 'package:flutter_test/flutter_test.dart';
import 'package:sprig/core/validators.dart';

void main() {
  test('email', () {
    expect(Validators.email(''), isNotNull);
    expect(Validators.email('abc'), isNotNull);
    expect(Validators.email('rizki@sprig.app'), isNull);
  });

  test('password', () {
    expect(Validators.password(''), isNotNull);
    expect(Validators.password('12345'), isNotNull);
    expect(Validators.password('123456'), isNull);
  });

  test('nama tanaman', () {
    expect(Validators.plantName(' '), isNotNull);
    expect(Validators.plantName('a'), isNotNull);
    expect(Validators.plantName('Monstera'), isNull);
    expect(Validators.plantName('x' * 31), isNotNull);
  });

  test('hari siram', () {
    expect(Validators.waterDays(''), isNotNull);
    expect(Validators.waterDays('0'), isNotNull);
    expect(Validators.waterDays('61'), isNotNull);
    expect(Validators.waterDays('7'), isNull);
  });
}
