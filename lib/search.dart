import 'package:lyrium/api.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/models.dart';
import 'package:flutter/material.dart';
import 'package:lyrium/datahelper.dart';
import 'package:lyrium/utils/search_terms.dart';
import 'package:lyrium/widgets/lyrics_sheet.dart';
import 'package:lyrium/widgets/settings.dart';
import 'package:provider/provider.dart';

enum SearchSource { global, local, now, recent }

class QuickSearch extends StatefulWidget {
  final Function(LyricsTrack, bool)? onResultSelected;
  final Track? initailQuery;

  const QuickSearch({super.key, this.onResultSelected, this.initailQuery});

  @override
  State<QuickSearch> createState() => _QuickSearchState();
}

class _QuickSearchState extends State<QuickSearch> {
  static var lastquery = "";
  static var lastresults = <LyricsTrack>[];
  static var queryhistory = <String>{};
  final TextEditingController _controller = TextEditingController();
  List<LyricsTrack>? _results;
  bool _loading = false;
  String? _error;
  SearchSource _mode = SearchSource.local;

  @override
  void dispose() {
    super.dispose();
  }

  late Track? initailQuery;

  @override
  void initState() {
    initailQuery = widget.initailQuery?.clearTemplates();

    _controller.text = initailQuery != null
        ? "${initailQuery?.trackName} - ${initailQuery?.artistName}"
        : lastquery;
    _results = lastresults;

    _search();
    super.initState();
  }

  void _clearInput() {
    _controller.clear();
    setState(() {
      _results = [];
      _error = null;
    });
  }

  String get query => _controller.text.trim();
  Future<void> _search() async {
    if (query.isEmpty && _mode != SearchSource.local) return;
    setState(() {
      _loading = true;
      _results = [];
      _error = null;
    });

    queryhistory.add(query);
    try {
      if (_mode == SearchSource.global) {
        await _searchLRCLIB();
      } else {
        final helper = DataHelper.instance;
        final tracks = await helper.searchTracks(query);
        setState(() {
          _results = tracks;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Search failed \n $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _searchLRCLIB() async {
    final api = ApiHandler();
    lastresults = await api.searchTracks(query).then((c) {
      if (initailQuery != null) {
        final target = initailQuery!.duration;
        c.sort((a, b) {
          final diffA = (a.track.duration - target).abs();
          final diffB = (b.track.duration - target).abs();
          return diffA.compareTo(diffB);
        });
      }
      return c;
    });
    lastquery = query;
    setState(() {
      _results = lastresults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: query.isNotEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Provider.of<MusicController>(
                context,
                listen: false,
              ).openEditor(context),
              label: Text("Create New"),
              icon: Icon(Icons.add),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultHeader(mode: true),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: TextField(
                style: TextStyle(fontSize: 20),
                autofillHints: queryhistory,
                autofocus: true,
                maxLines: 4,
                minLines: 1,
                controller: _controller,
                textInputAction: TextInputAction.search,
                onChanged: (_) => repriotirize(),
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  helperText:
                      'ex. ${SearchTerms.rule}', //, artists, or lyrics',
                  // border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsetsGeometry.all(8.0),
              child: Row(
                children: [
                  Wrap(
                    spacing: 8.0,
                    children: [
                      FilterChip(
                        label: const Text('LRCLIB'),
                        selected: _mode == SearchSource.global,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _mode = SearchSource.global;

                              _results = lastresults;
                              _error = null;
                              if (lastresults.isEmpty) {
                                _search();
                              }
                            });
                          }
                        },
                      ),

                      FilterChip(
                        label: const Text('Saved'),
                        selected: _mode == SearchSource.local,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _mode = SearchSource.local;
                              _results = [];
                              _error = null;
                            });
                            _search();
                          }
                        },
                      ),
                    ],
                  ),

                  Spacer(),

                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: showSettings,
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText(
                  _error!,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.redAccent),
                ),
              ),

            Expanded(
              child: Center(
                child: query.isEmpty && (_results?.isEmpty ?? false)
                    ? _buildNoResults('', Icons.search)
                    : _results?.isEmpty ?? true
                    ? _buildNoResults('Not Found', Icons.search_off)
                    : ResultsListView(
                        songs: _results!,
                        query: _controller.text,
                        onParentChanged: () {
                          _search();
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(String name, IconData icon) {
    return Consumer<MusicController>(
      builder: (BuildContext context, MusicController value, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }

  void repriotirize() {
    // final additional = _controller.text.substring(lastquery.length);
    // final words = additional
    //     .split(" ")
    //     .map((x) => x.trim())
    //     .where((t) => t != "")
    //     .toList()
    //     .reversed;

    // final priority = _results
    //     .where(
    //       (t) => words.any((word) => t.plainLyrics?.contains((word)) ?? false),
    //     )
    //     .toList();

    // _results.sort(
    //   (a, b) => priority.any((t) => t.id == a.id)
    //       ? 1
    //       : priority.any((t) => t.id == b.id)
    //       ? -1
    //       : 0,
    // );
    setState(() {});
  }

  void showSettings() {
    showAboutDialog(context: context, applicationVersion: packageInfo.version);
  }
}

class DefaultHeader extends StatelessWidget {
  final bool mode;
  const DefaultHeader({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<MusicController>(
          context,
          listen: false,
        ).setShowTrackMode(mode);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          onTap: () => Provider.of<MusicController>(
            context,
            listen: false,
          ).setShowTrackMode(mode),
          child: Center(
            child: Text(
              "Lyrium",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class ResultsListView extends StatelessWidget {
  final List<LyricsTrack> songs;
  final String query;
  final dynamic onParentChanged;
  const ResultsListView({
    super.key,
    required this.songs,
    required this.query,
    this.onParentChanged,
  });

  Widget _highlight(String text, String query, {TextStyle? style}) {
    if (query.isEmpty) return Text(text, style: style);
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    int index;
    while ((index = lower.indexOf(q, start)) != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + q.length),
          style: style?.copyWith(
            backgroundColor: const Color.fromARGB(255, 243, 255, 135),
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 29, 29, 11),
          ),
        ),
      );
      start = index + q.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }
    return RichText(
      text: TextSpan(children: spans, style: style),
    );
  }

  String _initials(String title, String artist) {
    final t = title.trim();
    if (t.isEmpty) {
      return artist
          .split(' ')
          .map((s) => s.isNotEmpty ? s[0] : '')
          .take(2)
          .join()
          .toUpperCase();
    }
    final parts = t.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: songs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final LyricsTrack itemd = songs[index];
        final Track item = itemd.track;
        final title = item.trackName;
        final artist = item.artistName ?? "";

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          leading: CircleAvatar(radius: 26, child: Icon(Icons.album_outlined)),
          title: _highlight(
            title,
            query,
            style: Theme.of(context)
                .textTheme
                .labelLarge, //TODO: Theme.of(context).listTileTheme.subtitleTextStyle does not work,
          ),
          subtitle: _highlight(
            artist,
            query,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children:
                [] // item.labels
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(s),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.indigo.shade700,
                          ),
                          backgroundColor: Colors.indigo.shade50,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    )
                    .toList(),
          ),
          onTap: () => showLyricsSheet(context, itemd, onParentChanged),
        );
      },
    );
  }
}
