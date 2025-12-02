import 'package:flutter_test/flutter_test.dart';
import 'package:lyrium/utils/search_terms.dart';

void main() {
  test('parses first, second, and quoted terms', () {
    final input = 'termwithoutquote - secondtermafterfistone "third" "fourth"';
    final result = SearchTerms.parse(input);

    expect(result.firstTerm, 'termwithoutquote');
    expect(result.secondTerm, 'secondtermafterfistone');
    expect(result.quotedTerms, ['third', 'fourth']);
    expect(result.unquotedExtras, isEmpty);
  });

  test('parses without hyphen', () {
    final input = 'alpha beta gamma delta "quoted"';
    final result = SearchTerms.parse(input);

    expect(result.firstTerm, 'alpha beta gamma delta');
    expect(result.secondTerm, '');
    expect(result.quotedTerms, ['quoted']);
    expect(result.unquotedExtras, ['gamma', 'delta']);
  });

  test('parses only quoted terms', () {
    final input = '  "one"   "two"  ';
    final result = SearchTerms.parse(input);

    expect(result.firstTerm, isNull);
    expect(result.secondTerm, isNull);
    expect(result.quotedTerms, ['one', 'two']);
    expect(result.unquotedExtras, isEmpty);
  });

  test('handles leading hyphen', () {
    final input = '- term2 "q"';
    final result = SearchTerms.parse(input);

    expect(result.firstTerm, isNull);
    expect(result.secondTerm, 'term2');
    expect(result.quotedTerms, ['q']);
  });

  test('handles trailing hyphen', () {
    final input = 'termA - "q"';
    final result = SearchTerms.parse(input);

    expect(result.firstTerm, 'termA');
    expect(result.secondTerm, isNull);
    expect(result.quotedTerms, ['q']);
  });

  test('handles multi-hyphen second term', () {
    final input = 'range 2020 - 2025 "phrase"';
    final result = SearchTerms.parse(input);

    expect(result.firstTerm, 'range 2020');
    expect(result.secondTerm, '2025');
    expect(result.quotedTerms, ['phrase']);
  });

  test('empty string', () {
    final result = SearchTerms.parse('');

    expect(result.firstTerm, isNull);
    expect(result.secondTerm, isNull);
    expect(result.quotedTerms, isEmpty);
    expect(result.unquotedExtras, isEmpty);
  });

  test("rule", () {
    final result = SearchTerms.parse(SearchTerms.rule);

    expect(result.firstTerm, "Title");
    expect(result.secondTerm, "Artist");
    expect(result.quotedTerms, ["Lyrics"]);
    expect(result.unquotedExtras, isEmpty);
  });
}
