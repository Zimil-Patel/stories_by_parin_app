import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  const EventScreen({
    super.key,
    required this.project,
  });

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents(
        widget.project.id,
      );

      context.read<PeopleProvider>().fetchPeople(
        widget.project.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),

      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------------------------
              // EVENTS SECTION
              // -------------------------------------------------

              const Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  10,
                ),
                child: Text(
                  'Events',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: Consumer<EventProvider>(
                  builder: (context, provider, child) {
                    // Show loading state.
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // Show error state.
                    if (provider.error != null) {
                      return Center(
                        child: Text(
                          provider.error!,
                        ),
                      );
                    }

                    // Show empty state.
                    if (provider.events.isEmpty) {
                      return const Center(
                        child: Text(
                          'No events found',
                        ),
                      );
                    }

                    final events = provider.events;

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      physics: const BouncingScrollPhysics(),

                      itemCount: events.length,

                      separatorBuilder: (
                          context,
                          index,
                          ) {
                        return const SizedBox(height: 8);
                      },

                      itemBuilder: (
                          context,
                          index,
                          ) {
                        final event = events[index];

                        return _EventCard(
                          eventName: event.name,
                          eventId: event.id,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PhotoScreen(
                                      event: event,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // -------------------------------------------------
              // PEOPLE SECTION
              // -------------------------------------------------

              const Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  10,
                ),
                child: Text(
                  'People',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(
                height: 190,
                child: Consumer<PeopleProvider>(
                  builder: (context, provider, child) {
                    // Show loading state.
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // Show error state.
                    if (provider.error != null) {
                      return Center(
                        child: Text(
                          provider.error!,
                        ),
                      );
                    }

                    // Show empty state.
                    if (provider.people.isEmpty) {
                      return const Center(
                        child: Text(
                          'No people found',
                        ),
                      );
                    }

                    return Row(
                      children: [
                        // -------------------------------------------------
                        // FIND ME
                        // -------------------------------------------------

                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                          ),
                          child: FindMeCard(
                            onTap: () async {
                              // Open selfie screen.
                              final selfie =
                              await Navigator.push<File>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const SelfieSearchScreen(),
                                ),
                              );

                              if (selfie == null ||
                                  !context.mounted) {
                                return;
                              }

                              final selfieProvider =
                              context.read<
                                  SelfieSearchProvider>();

                              // Search the selfie against
                              // the project's face clusters.
                              final success =
                              await selfieProvider.searchSelfie(
                                projectId:
                                widget.project.id,
                                selfie: selfie,
                              );

                              if (!context.mounted) {
                                return;
                              }

                              if (success) {
                                final result =
                                    selfieProvider.result;

                                if (result == null) {
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SelfieResultScreen(
                                          photos: result.photos,
                                        ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
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
                        ),

                        // -------------------------------------------------
                        // PEOPLE LIST
                        // -------------------------------------------------

                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                            ),
                            scrollDirection: Axis.horizontal,
                            physics:
                            const BouncingScrollPhysics(),

                            itemCount: provider.people.length,

                            itemBuilder: (
                                context,
                                index,
                                ) {
                              final person =
                              provider.people[index];

                              return Padding(
                                padding: const EdgeInsets.only(
                                  right: 12,
                                ),
                                child: PersonCard(
                                  person: person,

                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PersonPhotoScreen(
                                              projectId:
                                              widget.project.id,
                                              faceId:
                                              person.faceId,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),

          // -------------------------------------------------
          // SELFIE SEARCH LOADING OVERLAY
          // -------------------------------------------------

          Consumer<SelfieSearchProvider>(
            builder: (
                context,
                provider,
                child,
                ) {
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


// ---------------------------------------------------------
// EVENT CARD
// ---------------------------------------------------------

class _EventCard extends StatelessWidget {
  final String eventName;
  final int eventId;
  final VoidCallback onTap;

  const _EventCard({
    required this.eventName,
    required this.eventId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,

      borderRadius: BorderRadius.circular(14),

      child: InkWell(
        borderRadius: BorderRadius.circular(14),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          child: Row(
            children: [
              // Event icon.
              Container(
                width: 46,
                height: 46,

                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(
                  Icons.photo_library_outlined,

                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 14),

              // Event information.
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      eventName,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Event ID: $eventId',

                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}