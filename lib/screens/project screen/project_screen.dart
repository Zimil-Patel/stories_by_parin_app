import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/project_provider.dart';
import 'package:stories_by_parin/screens/event%20screen/event_screen.dart';
import 'package:stories_by_parin/utils/images.dart';
import 'package:stories_by_parin/widgets/app_background.dart';

import 'components/project_card.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 8.0),
            child: AppBar(
              scrolledUnderElevation: 0,
              title: const Text('Projects'),
              backgroundColor: Colors.white24,
            ),
          ),
        ),
      ),

      body: AppBackground(
        child: Consumer<ProjectProvider>(
          builder: (_, provider, child) {
            /// if projects are loading show loader
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
        
            /// if there is any error show error
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.error ?? "Something went wrong"),
        
                    TextButton(
                      onPressed: () {
                        context.read<ProjectProvider>().fetchProjects();
                      },
                      child: Text('Retry', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              );
            }
        
            /// show all projects list if no projects then show message
            if (provider.projects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("No projects found"),
        
                    TextButton(
                      onPressed: () {
                        context.read<ProjectProvider>().fetchProjects();
                      },
                      child: Text('Retry', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              );
            }
        
            final projects = provider.projects;
        
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProjectProvider>().fetchProjects();
              },
              child: ListView.builder(
                itemCount: projects.length,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final project = projects[index];
        
                  return ProjectCard(
                    project: project,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventScreen(project: project),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
