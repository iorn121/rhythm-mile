import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_mile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the login screen', (tester) async {
    dotenv.testLoad(fileInput: '''
SPOTIFY_CLIENT_ID=test
SPOTIFY_REDIRECT_URL=rhythm-mile://callback
SPOTIFY_CLIENT_SECRET=test
''');

    await tester.pumpWidget(const MyApp());

    expect(find.text('Rhythm Mile'), findsOneWidget);
    expect(find.text('Spotifyでログイン'), findsOneWidget);
  });
}
