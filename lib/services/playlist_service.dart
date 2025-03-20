import 'package:spotify/spotify.dart';

class PlaylistService {
  final SpotifyApi _spotify;

  PlaylistService(this._spotify);

  Future<Playlist> createBpmPlaylist({
    required String name,
    required int targetBpm,
    required int durationMinutes,
    required PlaylistSimple sourcePlaylist,
  }) async {
    // 1. ソースプレイリストから曲を取得
    final tracks = await _spotify.playlists
        .getTracksByPlaylistId(sourcePlaylist.id!)
        .all();

    // 2. BPMに合う曲をフィルタリング（仮の実装：実際のBPM取得はSpotify APIで提供されていないため）
    final filteredTracks = tracks;
    // TODO: Audio Analysis APIを使用してBPMを取得し、フィルタリング

    // 3. 指定された時間に収まるように曲を選択
    final targetDurationMs = durationMinutes * 60 * 1000;
    final selectedTracks = <Track>[];
    var currentDurationMs = 0;

    for (final track in filteredTracks) {
      if (currentDurationMs >= targetDurationMs) break;
      if (track.durationMs != null) {
        currentDurationMs += track.durationMs!;
        selectedTracks.add(track);
      }
    }

    // 4. 新しいプレイリストを作成
    final me = await _spotify.me.get();
    final playlist = await _spotify.playlists.createPlaylist(
      me.id!,
      name,
      description: 'BPM: $targetBpm, Duration: $durationMinutes minutes',
    );

    // 5. 選択した曲を新しいプレイリストに追加
    if (selectedTracks.isNotEmpty) {
      await _spotify.playlists.addTracks(
        selectedTracks.map((track) => track.uri!).toList(),
        playlist.id!,
      );
    }

    return playlist;
  }
}
