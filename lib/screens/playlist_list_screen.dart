import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'create_playlist_screen.dart';
import '../auth/spotify_auth.dart';

class PlaylistListScreen extends StatefulWidget {
  const PlaylistListScreen({super.key});

  @override
  State<PlaylistListScreen> createState() => _PlaylistListScreenState();
}

class _PlaylistListScreenState extends State<PlaylistListScreen> {
  List<spotify.PlaylistSimple> _playlists = [];
  bool _isLoading = true;
  final _spotifyAuth = SpotifyAuth();

  @override
  void initState() {
    super.initState();
    print('initStateが呼び出されました'); // デバッグ用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('addPostFrameCallbackが呼び出されました'); // デバッグ用
      _loadPlaylists();
    });
  }

  Future<void> _loadPlaylists() async {
    print('_loadPlaylistsが呼び出されました'); // デバッグ用
    setState(() {
      _isLoading = true;
    });
    try {
      print('プレイリストの読み込みを開始');
      await SpotifyAuth.initialize();
      final playlists = await _spotifyAuth.getUserPlaylists();
      print('プレイリストの取得に成功: ${playlists.length}件');
      if (mounted) {
        setState(() {
          _playlists = playlists;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('プレイリストの読み込みに失敗しました: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プレイリストの取得に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _createNewPlaylist() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePlaylistScreen(),
      ),
    );

    if (result == true) {
      _loadPlaylists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイリスト'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewPlaylist,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playlists.isEmpty
              ? const Center(
                  child: Text('プレイリストがありません'),
                )
              : ListView.builder(
                  itemCount: _playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = _playlists[index];
                    return ListTile(
                      leading: playlist.images?.isNotEmpty == true
                          ? Image.network(
                              playlist.images!.first.url!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.music_note),
                      title: Text(playlist.name ?? '無名のプレイリスト'),
                      subtitle: const Text('タップして詳細を表示'),
                      onTap: () {
                        // TODO: プレイリスト詳細画面への遷移
                      },
                    );
                  },
                ),
    );
  }
}
