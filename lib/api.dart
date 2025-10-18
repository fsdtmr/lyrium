import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lyrium/models.dart';

class ApiHandler {
  final String baseUrl;

  ApiHandler({this.baseUrl = 'https://lrclib.net'});

  Future<T> _get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParameters);
    final response = await http.get(
      uri,
      headers: {'User-Agent': 'test/1.0 (test)'},
    );
    switch (response.statusCode) {
      case 404:
        throw Exception("This music did not match any songs");
      default:
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as T;
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  Future<List<LyricsTrack>> searchTracks(String query) async {
    final res = await _get<List<dynamic>>(
      '/api/search',
      queryParameters: {'q': query},
    );
    return mapTracks(res);
  }

  Future<List<LyricsTrack>> find(TrackInfo inf) async {
    final res = await _get(
      '/api/get',
      queryParameters: {
        'artist_name': inf.artistName,
        'track_name': inf.trackName,
        'album_name': inf.albumName,
        'duration': inf.durationseconds.toString(),
      },
    );
    return mapTracks([res]);
  }

  List<LyricsTrack> mapTracks(List<dynamic> jsonList) {
    List<LyricsTrack> tracks = [];
    for (var element in jsonList) {
      try {
        final track = LyricsTrack.fromJson(element as Map<String, dynamic>);

        tracks.add(track);
      } catch (e) {
        print(e);
      }
    }

    return tracks;
  }
}
