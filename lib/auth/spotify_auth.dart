import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:spotify/spotify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class SpotifyAuth {
  static const _scopes = [
    'user-read-private',
    'user-read-email',
    'playlist-read-private',
    'playlist-modify-public',
    'playlist-modify-private',
  ];

  static AppLinks? _appLinks;
  static bool _isAuthenticating = false;
  static StreamSubscription<Uri>? _subscription;
  static Completer<Uri>? _authCompleter;
  static bool _isInitialized = false;
  static Future<void>? _initializationFuture;
  static SpotifyApi? _spotifyApi;

  /// PKCE用のランダム文字列を生成
  static String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// コードチャレンジを生成
  static String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes)
      .replaceAll('=', '')
      .replaceAll('+', '-')
      .replaceAll('/', '_');
  }

  static Future<SpotifyApi> initialize() async {
    print('initialize()が呼び出されました'); // デバッグ用
    if (_isInitialized && _spotifyApi != null) {
      print('既存のSpotifyApiインスタンスを返却します'); // デバッグ用
      return _spotifyApi!;
    }

    print('初期化を開始します'); // デバッグ用
    _initializationFuture ??= _initialize();
    await _initializationFuture;
    print('初期化が完了しました'); // デバッグ用
    
    if (_spotifyApi != null) {
      return _spotifyApi!;
    }
    
    return await authenticate();
  }

  static Future<void> _initialize() async {
    print('_initialize()が呼び出されました'); // デバッグ用
    if (!_isInitialized) {
      print('AppLinksの初期化を開始'); // デバッグ用
      _appLinks = AppLinks();
      // 初期リンクをクリア
      try {
        final initialLink = await _appLinks!.getInitialAppLink();
        print('初期リンク: $initialLink'); // デバッグ用
      } catch (e) {
        print('初期リンク取得エラー: $e'); // デバッグ用
      }
      _isInitialized = true;
      print('AppLinksの初期化完了'); // デバッグ用
    } else {
      print('既に初期化済みです'); // デバッグ用
    }
  }

  static Future<void> _setupAuthListener() async {
    print('認証リスナーのセットアップ開始'); // デバッグ用
    
    // 既存のサブスクリプションをクリーンアップ
    await _subscription?.cancel();
    _subscription = null;
    _authCompleter = Completer<Uri>();

    _subscription = _appLinks!.uriLinkStream.listen(
      (uri) {
        print('URIを受信: $uri'); // デバッグ用
        if (!_authCompleter!.isCompleted) {
          _authCompleter!.complete(uri);
        }
      },
      onError: (error) {
        print('URIリスナーエラー: $error'); // デバッグ用
        if (!_authCompleter!.isCompleted) {
          _authCompleter!.completeError(error);
        }
      },
      cancelOnError: false,
    );

    print('認証リスナーのセットアップ完了'); // デバッグ用
  }

  static Future<void> _cleanup() async {
    print('クリーンアップ開始'); // デバッグ用
    await _subscription?.cancel();
    _subscription = null;
    _authCompleter = null;
    _isAuthenticating = false;
    print('クリーンアップ完了'); // デバッグ用
  }

  static Future<SpotifyApi> authenticate() async {
    if (_spotifyApi != null) {
      print('既存のSpotifyApiインスタンスを返却'); // デバッグ用
      return _spotifyApi!;
    }

    if (_isAuthenticating) {
      print('認証プロセスが進行中'); // デバッグ用
      throw Exception('認証プロセスが進行中です。しばらくお待ちください。');
    }

    _isAuthenticating = true;
    print('認証プロセス開始: ${DateTime.now()}'); // デバッグ用

    try {
      if (!_isInitialized) {
        await _initialize();
      }
      await _setupAuthListener();

      final clientId = dotenv.env['SPOTIFY_CLIENT_ID'];
      final redirectUri = dotenv.env['SPOTIFY_REDIRECT_URL'];
      final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'];

      if (clientId == null || redirectUri == null || clientSecret == null) {
        throw Exception('環境変数が設定されていません。.envファイルを確認してください。');
      }

      // PKCE認証用のコード生成
      final codeVerifier = _generateRandomString(128);
      final codeChallenge = _generateCodeChallenge(codeVerifier);

      final state = DateTime.now().millisecondsSinceEpoch.toString();
      final authUri = Uri.https('accounts.spotify.com', '/authorize', {
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': _scopes.join(' '),
        'code_challenge_method': 'S256',
        'code_challenge': codeChallenge,
        'show_dialog': 'true',
        'state': state,
      });

      print('認証URL生成完了: $authUri'); // デバッグ用

      if (!await launchUrl(
        authUri,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('認証URLを開けませんでした');
      }

      print('ブラウザで認証URL開始'); // デバッグ用

      final uri = await _authCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw Exception('認証がタイムアウトしました。再度お試しください。');
        },
      );

      print('コールバックURI受信: $uri'); // デバッグ用

      // 受信したstateの検証
      if (uri.queryParameters['state'] != state) {
        throw Exception('不正なstate値を受信しました');
      }

      final code = uri.queryParameters['code'];
      if (code == null) throw Exception('認証コードの取得に失敗しました');

      final tokenUri = Uri.https('accounts.spotify.com', '/api/token');
      
      final requestBody = {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': codeVerifier,
        'client_id': clientId,
      };

      print('トークンリクエスト準備完了'); // デバッグ用

      final encodedBody = requestBody.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await http.post(
        tokenUri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: encodedBody,
      );

      print('トークンレスポンス受信: ${response.statusCode}'); // デバッグ用

      if (response.statusCode != 200) {
        print('トークンレスポンスエラー: ${response.body}'); // デバッグ用
        Map<String, dynamic> errorBody;
        try {
          errorBody = jsonDecode(response.body);
        } catch (e) {
          errorBody = {'error': 'unknown', 'error_description': response.body};
        }
        throw Exception('アクセストークンの取得に失敗しました: ${errorBody['error_description'] ?? errorBody['error'] ?? response.body}');
      }

      final tokenData = jsonDecode(response.body);
      if (!tokenData.containsKey('access_token')) {
        throw Exception('アクセストークンが応答に含まれていません');
      }

      print('認証完了: ${DateTime.now()}'); // デバッグ用

      final credentials = SpotifyApiCredentials(
        clientId,
        clientSecret,
        accessToken: tokenData['access_token'],
        refreshToken: tokenData['refresh_token'],
        scopes: _scopes,
        expiration: DateTime.now().add(
          Duration(seconds: tokenData['expires_in'] as int),
        ),
      );

      _spotifyApi = SpotifyApi(credentials);
      return _spotifyApi!;
    } catch (e, stackTrace) {
      print('認証エラー: $e'); // デバッグ用
      print('スタックトレース: $stackTrace'); // デバッグ用
      await _cleanup();
      rethrow;
    } finally {
      await _cleanup();
    }
  }

  static Future<void> dispose() async {
    print('完全なクリーンアップを開始'); // デバッグ用
    await _cleanup();
    _spotifyApi = null;
    _appLinks = null;
    _isInitialized = false;
    _initializationFuture = null;
    print('完全なクリーンアップ完了'); // デバッグ用
  }
} 