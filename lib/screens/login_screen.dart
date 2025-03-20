import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import '../auth/spotify_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Rhythm Mile',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Spotifyにログインしています...'),
                      duration: Duration(seconds: 30),
                    ),
                  );

                  final spotify = await SpotifyAuth.initialize();
                  
                  if (context.mounted) {
                    scaffoldMessenger.hideCurrentSnackBar();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(spotify: spotify),
                      ),
                    );
                  }
                } catch (e, stackTrace) {
                  print('ログインエラー: $e');
                  print('スタックトレース: $stackTrace');
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ログインに失敗しました'),
                            Text(
                              e.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 10),
                        action: SnackBarAction(
                          label: '再試行',
                          textColor: Colors.white,
                          onPressed: () async {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            await SpotifyAuth.dispose();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Spotifyにログインしています...'),
                                  duration: Duration(seconds: 30),
                                ),
                              );
                              try {
                                final spotify = await SpotifyAuth.initialize();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(spotify: spotify),
                                    ),
                                  );
                                }
                              } catch (retryError) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('再試行に失敗しました: $retryError'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.music_note),
              label: const Text('Spotifyでログイン'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 