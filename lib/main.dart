import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/auth_provider.dart';
import 'package:stories_by_parin/providers/event_provider.dart';
import 'package:stories_by_parin/providers/people_provider.dart';
import 'package:stories_by_parin/providers/person_photo_provider.dart';
import 'package:stories_by_parin/providers/photo_provider.dart';
import 'package:stories_by_parin/providers/project_provider.dart';
import 'package:stories_by_parin/providers/selfie_search_provider.dart';
import 'package:stories_by_parin/screens/auth%20screen/auth_state.dart';
import 'package:stories_by_parin/screens/auth%20screen/login_screen.dart';
import 'package:stories_by_parin/screens/project%20screen/project_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  /// Initialise firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(StoriesBYP());
}

class StoriesBYP extends StatelessWidget {
  const StoriesBYP({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(),),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => PeopleProvider()),
        ChangeNotifierProvider(create: (_) => PersonPhotoProvider()),
        ChangeNotifierProvider(create: (_) => SelfieSearchProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stories BYP',
        theme: ThemeData(useMaterial3: true),
        home: const AuthGate(),
      ),
    );
  }
}
