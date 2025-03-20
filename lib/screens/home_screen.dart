import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

class HomeScreen extends StatefulWidget {
  final SpotifyApi spotify;

  const HomeScreen({
    Key? key,
    required this.spotify,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PlaylistSimple>? _playlists;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final me = await widget.spotify.me.get();
      final playlistsPage = await widget.spotify.playlists.me.all();
      
      setState(() {
        _playlists = playlistsPage.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'プレイリストの読み込みに失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rhythm Mile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPlaylists,
                        child: const Text('再読み込み'),
                      ),
                    ],
                  ),
                )
              : _playlists?.isEmpty ?? true
                  ? const Center(child: Text('プレイリストがありません'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _playlists!.length,
                      itemBuilder: (context, index) {
                        final playlist = _playlists![index];
                        Widget? leadingImage;
                        if (playlist.images?.isNotEmpty ?? false) {
                          leadingImage = Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(playlist.images!.first.url ?? ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                        return Card(
                          child: ListTile(
                            leading: leadingImage ?? const Icon(Icons.music_note),
                            title: Text(playlist.name ?? '名称不明'),
                            subtitle: Text('${playlist.tracksLink?.total ?? 0} 曲'),
                            onTap: () {
                              // TODO: プレイリストの詳細画面へ遷移
                            },
                          ),
                        );
                      },
                    ),
    );
  }
} 