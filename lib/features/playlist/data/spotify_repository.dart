import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify/spotify.dart';

class SpotifyRepository {
  final SpotifyApi _spotify;

  SpotifyRepository(this._spotify);

  Future<List<PlaylistSimple>> getUserPlaylists() async {
    final playlists = <PlaylistSimple>[];
    var offset = 0;
    const limit = 20;
    
    while (true) {
      final page = await _spotify.me.playlists.saved().getPage(limit, offset);
      if (page.items == null || page.items!.isEmpty) break;
      
      playlists.addAll(page.items!);
      offset += limit;
      
      if (page.items!.length < limit) break;
    }
    
    return playlists;
  }

  Future<Playlist> getPlaylist(String playlistId) async {
    return await _spotify.playlists.get(playlistId);
  }

  Future<Playlist> createPlaylist(String name, {String? description}) {
    return _spotify.me.playlists.create(
      name,
      description: description,
      public: false,
    );
  }

  Future<void> addTracksToPlaylist(String playlistId, List<String> trackUris) async {
    await _spotify.playlists.addTracks(trackUris, playlistId);
  }
}

final spotifyRepositoryProvider = Provider<SpotifyRepository>((ref) {
  throw UnimplementedError('SpotifyRepositoryを初期化する前にSpotifyApiを設定する必要があります');
}); 