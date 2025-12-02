// dart_search_parser_v2.dart
// Updated parser to match the provided unit tests.

import 'package:lyrium/models.dart';
import 'package:lyrium/utils/string.dart';

class SearchTerms {
  final String? firstTerm;
  final String? secondTerm;
  final List<String> quotedTerms;
  final List<String> unquotedExtras;

  SearchTerms({
    this.firstTerm,
    this.secondTerm,
    List<String>? quotedTerms,
    List<String>? unquotedExtras,
  }) : quotedTerms = quotedTerms ?? [],
       unquotedExtras = unquotedExtras ?? [];

  @override
  String toString() {
    return 'SearchTerms(firstTerm: \$firstTerm, secondTerm: \$secondTerm, quoted: \$quotedTerms, extras: \$unquotedExtras)';
  }

  static const rule = "Title - Artist \"Lyrics\"";
  factory SearchTerms.parse(String input) {
    final RegExp quoteRe = RegExp(r'"([^"]+)"');
    final quoted = <String>[];

    for (final m in quoteRe.allMatches(input)) {
      final g = m.group(1);
      if (g != null && g.trim().isNotEmpty) quoted.add(g.trim());
    }

    String cleaned = input.replaceAll(quoteRe, ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    String? first;
    String? second;
    final extras = <String>[];

    if (cleaned.isNotEmpty) {
      final hyphenSplit = cleaned.split(RegExp(r'\s*-\s*'));
      if (hyphenSplit.length >= 2) {
        // Hyphen case: left is first, right is second (join rest)
        first = hyphenSplit.first.trim();
        second = hyphenSplit.sublist(1).join(' - ').trim();
        if (first.isEmpty) first = null;
        if (second.isEmpty) second = null;
      } else {
        // No hyphen: firstTerm is entire cleaned string, secondTerm is empty string (not null)
        final tokens = cleaned.split(' ');
        first = cleaned;
        second = '';
        if (tokens.length > 2) {
          extras.addAll(
            tokens.sublist(2).map((t) => t.trim()).where((t) => t.isNotEmpty),
          );
        }
      }
    }

    return SearchTerms(
      firstTerm: first.isValid ? first : null,
      secondTerm: second,
      quotedTerms: quoted,
      unquotedExtras: extras,
    );
  }
}

extension ClearInof on TrackInfo {
  static List<String> advertisement = ["Advertisement", "Sponsored"];
  static List<String> clearArtists = [
    "•",
    "Recommended for you",
    "Unknown Artist",
  ];

  static List<String> replacewithSpace = ["/"];
  TrackInfo clearTemplates() {
    String clearedTrack = trackName;
    String clearedArtist = artistName;
    String clearedAlbum = albumName;

    for (var e in advertisement) {
      clearedTrack = replaceFirstCaseInsensitive(clearedTrack, e).trim();
    }

    for (var e in clearArtists) {
      clearedArtist = replaceFirstCaseInsensitive(clearedArtist, e).trim();
    }

    for (var e in replacewithSpace) {
      clearedArtist = clearedArtist.replaceAll(e, " ").trim();
    }

    return TrackInfo(
      artistName: clearedArtist,
      trackName: clearedTrack,
      albumName: clearedAlbum,
      durationseconds: durationseconds,
    );
  }
}
