import 'package:flutter_test/flutter_test.dart';
import 'package:lyrium/utils/lrc.dart';

main() {
  test("Test LRC", () {
    final parsed = toLRCLineList("");
    assert(!parsed.validate());

    final plain = parsed.toPlainText();

    final plainmapped = parsed.remapPlainText(plain);
    final mappedstring = plainmapped.toLRCString();

    final remappedlrc = toLRCLineList(mappedstring);
    assert(!remappedlrc.validate());

    final rhs = remappedlrc.toLRCString();
    final lhs = parsed.toLRCString();

    assert(lhs == rhs);
  });
}
