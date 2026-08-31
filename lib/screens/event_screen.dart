import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/models/event_model.dart';
import 'package:stories_by_parin/models/project_model.dart';
import 'package:stories_by_parin/providers/event_provider.dart';
import 'package:stories_by_parin/screens/photo_screen.dart';

class EventScreen extends StatefulWidget {
  final Project project;

  const EventScreen({super.key, required this.project});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents(widget.project.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events')),

      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          /// if events are loading show loader
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// if there is any error show error
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          /// show all events list if no event then show message
          if (provider.events.isEmpty) {
            return Center(child: Text("No events found"));
          }

          final events= provider.events;

          return ListView.builder(
            itemCount: events.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final event = events[index];

              return ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoScreen(event: event),));
                },
                title: Text(event.name),
                subtitle: Text("Event ID: ${event.id}"),
                trailing: Icon(Icons.chevron_right_rounded),
              );
            },
          );
        },
      ),
    );
  }
}
