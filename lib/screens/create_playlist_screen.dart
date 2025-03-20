import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import '../auth/spotify_auth.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bpmController = TextEditingController();
  final _durationController = TextEditingController();
  PlaylistSimple? _selectedReferencePlaylist;
  List<PlaylistSimple> _referencePlaylists = [];
  bool _isLoading = false;
  final _spotifyAuth = SpotifyAuth();

  @override
  void initState() {
    super.initState();
    _loadReferencePlaylists();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bpmController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadReferencePlaylists() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await SpotifyAuth.initialize();
      final playlists = await _spotifyAuth.getUserPlaylists();
      setState(() {
        _referencePlaylists = playlists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プレイリストの取得に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _createPlaylist() async {
    if (!_formKey.currentState!.validate() ||
        _selectedReferencePlaylist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('すべての項目を入力してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _spotifyAuth.createPlaylist(
        name: _nameController.text,
        targetBpm: int.parse(_bpmController.text),
        durationMinutes: int.parse(_durationController.text),
        referencePlaylist: _selectedReferencePlaylist!,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プレイリストの作成に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイリストを作成'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'プレイリスト名',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'プレイリスト名を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bpmController,
                      decoration: const InputDecoration(
                        labelText: '目標BPM',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '目標BPMを入力してください';
                        }
                        final bpm = int.tryParse(value);
                        if (bpm == null || bpm < 60 || bpm > 200) {
                          return '60-200の間の数値を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: '再生時間（分）',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '再生時間を入力してください';
                        }
                        final duration = int.tryParse(value);
                        if (duration == null ||
                            duration < 1 ||
                            duration > 180) {
                          return '1-180の間の数値を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<PlaylistSimple>(
                      value: _selectedReferencePlaylist,
                      decoration: const InputDecoration(
                        labelText: '参考プレイリスト',
                        border: OutlineInputBorder(),
                      ),
                      items: _referencePlaylists.map((playlist) {
                        return DropdownMenuItem(
                          value: playlist,
                          child: Text(playlist.name ?? '無名のプレイリスト'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedReferencePlaylist = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return '参考プレイリストを選択してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _createPlaylist,
                      child: const Text('プレイリストを作成'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
