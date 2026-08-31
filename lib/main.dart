import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/event_provider.dart';
import 'package:stories_by_parin/providers/photo_provider.dart';
import 'package:stories_by_parin/providers/project_provider.dart';
import 'package:stories_by_parin/screens/photo%20screen/project_screen.dart';

void main() {
  runApp(StoriesBYP());
}

class StoriesBYP extends StatelessWidget {
  const StoriesBYP({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stories BYP',
        theme: ThemeData(useMaterial3: true),
        home: const ProjectScreen(),
      ),
    );
  }
}
