import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/models/event_model.dart';
import 'package:stories_by_parin/models/project_model.dart';
import 'package:stories_by_parin/providers/event_provider.dart';
import 'package:stories_by_parin/providers/people_provider.dart';
import 'package:stories_by_parin/providers/selfie_search_provider.dart';
import 'package:stories_by_parin/screens/event%20screen/components/person_card.dart';
import 'package:stories_by_parin/screens/person%20photos%20screen/person_photos_screen.dart';
import 'package:stories_by_parin/screens/photo%20screen/photo_screen.dart';

import '../selfie result screen/selfie_result_screen.dart';
import '../selfie screen/selfie_search_screen.dart';
import 'components/find_me_card.dart';

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

      context.read<PeopleProvider>().fetchPeople(widget.project.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events')),

      body: Stack(
        children: [

          /// Event Screen content
          Column(
            children: [
              Consumer<EventProvider>(
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

                  final events = provider.events;

                  return Expanded(
                    child: ListView.builder(
                      itemCount: events.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final event = events[index];

                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoScreen(event: event),
                              ),
                            );
                          },
                          title: Text(event.name),
                          subtitle: Text("Event ID: ${event.id}"),
                          trailing: Icon(Icons.chevron_right_rounded),
                        );
                      },
                    ),
                  );
                },
              ),

              /// People faces
              Consumer<PeopleProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(child: Text(provider.error!));
                  }

                  if (provider.people.isEmpty) {
                    return const Center(child: Text('No people found'));
                  }

                  return SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Row(
                      children: [
                        FindMeCard(
                          onTap: () async {
                            /// Show Loader/error/Navigation on selfie click
                            final selfie = await Navigator.push<File>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SelfieSearchScreen(),
                              ),
                            );

                            if (selfie == null || !context.mounted) {
                              return;
                            }

                            final selfieProvider = context.read<SelfieSearchProvider>();

                            final success = await selfieProvider.searchSelfie(projectId: widget.project.id, selfie: selfie);

                            if(!context.mounted){
                              return;
                            }

                            if(success){
                              final result = selfieProvider.result;

                              if(result == null){
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SelfieResultScreen(
                                    photos: result.photos,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    selfieProvider.error ??
                                        'Unable to find your photos.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),

                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),

                            scrollDirection: Axis.horizontal,

                            itemCount: provider.people.length,

                            itemBuilder: (context, index) {
                              final person = provider.people[index];

                              return PersonCard(
                                person: person,

                                onTap: () {
                                  // We'll connect this to the person's
                                  // matching photos screen next.
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PersonPhotoScreen(
                                        projectId: widget.project.id,
                                        faceId: person.faceId,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          /// Selfie search loading overlay
          Consumer<SelfieSearchProvider>(
            builder: (context, provider, child) {
              if (!provider.isLoading) {
                return const SizedBox.shrink();
              }

              return const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
