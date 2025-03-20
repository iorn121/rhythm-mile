import 'package:flutter/material.dart' hide Image;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rhythm_mile/auth/spotify_auth.dart';
import 'package:rhythm_mile/features/playlist/data/spotify_repository.dart';
import 'package:spotify/spotify.dart';

final spotifyApiProvider = FutureProvider<SpotifyApi>((ref) async {
  return await SpotifyAuth.authenticate();
});

final spotifyRepositoryProvider = Provider<SpotifyRepository>((ref) {
  final spotifyApi = ref.watch(spotifyApiProvider).value;
  if (spotifyApi == null) {
    throw UnimplementedError('SpotifyApiが初期化されていません');
  }
  return SpotifyRepository(spotifyApi);
});

final userPlaylistsProvider = FutureProvider<List<PlaylistSimple>>((ref) async {
  final repository = ref.watch(spotifyRepositoryProvider);
  return repository.getUserPlaylists();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(userPlaylistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rhythm Mile'),
      ),
      body: playlistsAsync.when(
        data: (playlists) => ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return ListTile(
              leading: playlist.images?.isNotEmpty ?? false
                  ? Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(playlist.images!.first.url!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : const Icon(Icons.music_note),
              title: Text(playlist.name ?? 'Untitled Playlist'),
              subtitle: const Text('Loading tracks...'),
              onTap: () {
                // TODO: Navigate to playlist detail screen
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create new running playlist
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 