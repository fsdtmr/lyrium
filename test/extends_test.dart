import 'package:flutter_test/flutter_test.dart';
import 'package:lyrium/utils/duration.dart';

void main() {
  group('DoubleDuration extension', () {
    test('toDuration returns correct Duration for double', () {
      expect(1.5.toDuration(), const Duration(seconds: 1, milliseconds: 500));
      expect(0.0.toDuration(), const Duration());
      expect(2.999.toDuration(), const Duration(seconds: 2, milliseconds: 999));
    });

    test("Duration toDouble returns correct double for Duration", () {
      expect(const Duration(seconds: 1, milliseconds: 500).toDouble(), 1.5);
      expect(const Duration().toDouble(), 0.0);
      expect(const Duration(seconds: 2, milliseconds: 999).toDouble(), 2.999);
    });
  });
}
