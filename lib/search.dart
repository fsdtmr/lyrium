import 'package:flutter/material.dart';
import 'package:lyrium/api.dart';
import 'package:lyrium/datahelper.dart'; // Make sure this import is correct for your DataHelper
import 'package:lyrium/models.dart';
import 'package:lyrium/utils/duration.dart';

enum SearchSource { global, local }

var lastresults = <LyricsTrack>[];
var lastquery = "";

class SearchSelector extends StatefulWidget {
  final Function(LyricsTrack, bool)?  onResultSelected;
  final TrackInfo? initailQuery;

  const SearchSelector({super.key, this.onResultSelected, this.initailQuery});

  @override
  State<SearchSelector> createState() => _SearchSelectorState();
}

class _SearchSelectorState extends State<SearchSelector> {
  final TextEditingController _controller = TextEditingController();
  List<LyricsTrack> _results = [];
  bool _loading = false;
  String? _error;
  SearchSource _mode = SearchSource.local;
  
  bool _expand_results =false;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty && _mode != SearchSource.local) return;
    setState(() {
      _loading = true;
      _results = [];
      _error = null;
    });
    try {
      if (_mode == SearchSource.global) {
        final api = ApiHandler();
        lastresults = await api.searchTracks(query);
        lastquery = query;
        setState( () {
          _results = lastresults;
        });
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _controller.text = widget.initailQuery != null ? "${widget.initailQuery?.trackName}" : lastquery;
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

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Column(
        children: [
          AppBar(
            leading: BackButton(),
            automaticallyImplyLeading: false,
            title: TextField(
              autofocus: true,
              controller: _controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 15),

                border: InputBorder.none,
                isDense: false,

                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearInput,
                      )
                    // suffixIcon:
                    //     ?
                    //     : null,
                    : null,
              ),
              onChanged: (_) => repriotirize(),
              onSubmitted: (_) => _search(),
            ),

            // elevation: 1,
          ),
          const Divider(height: 1),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('LRCLIB'),
                        selected: _mode == SearchSource.global,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _mode = SearchSource.global;
                              _results = [];
                              _error = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Saved'),
                        selected: _mode == SearchSource.local,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _mode = SearchSource.local;
                              _results = [];
                              _error = null;
                            });
                          }
                        },
                      ),

                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('Expand'), selected: _expand_results, onSelected: (value) => setState(() {
                        _expand_results = value;
                      }),)
                    ],
                  ),
                ),

                Expanded(
                  child: Builder(
                    builder: (context) {
                      return _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                          ? Center(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : _results.isEmpty && _controller.text.isNotEmpty
                          ? const Center(child: Text('No results found.'))
                          : ListView.separated(
                              itemCount: _results.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final track = _results[index];

                                return GestureDetector(
                                  onLongPress: () =>
                                      showfileoptions(context, track),
                                  child: ListTile(
                                    title: Text(track.trackName),
                                    subtitle: Text(
                                      '  ${track.albumName ?? ""} - ${track.artistName ?? "Unknown Artist"} + ${!_expand_results ? "" : track.plainLyrics}',
                                    ),
                                    trailing: Text(
                                      track.duration.toShortString()
                                    ),
                                    onTap: () {
                                      widget.onResultSelected?.call(track , SearchSource.global == _mode);
                                    },
                                  ),
                                );
                              },
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showfileoptions(BuildContext context, LyricsTrack track) async {
    await showDialog(
      context: context,
      builder: (c) {
        return ListView(
          children: [

            Text("Track ID: ${track.id}"),
            Text("Track Name: ${track.trackName}"),
            Text("Artist Name: ${track.artistName ?? "Unknown Artist"}"),
            Text("Album Name: ${track.albumName ?? "Unknown Album"}"),
            Text(
              "Duration: ${track.duration.toShortString()}",
            ),
            Text("Instrumental: ${track.instrumental == true ? "Yes" : "No"}"),
            Text("Plain Lyrics: ${track.plainLyrics ?? "No Lyrics"}"),
            Text("Synced Lyrics: ${track.syncedLyrics ?? "No Synced Lyrics"}"),

            IconButton(
              onPressed: () => DataHelper.instance
                  .delete(track)
                  .then((t) => Navigator.of(context).pop()),
              icon: Icon(Icons.delete, color: Colors.red),
            ),

            TextButton(onPressed: (){
              DataHelper.instance.delete(track);

              Navigator.of(context).pop();
            }, child: Text("Delete"))

            
          ],
        );
      },
    );

    if (_mode != SearchSource.global) {
      await _search();
    }
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
}
