import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/project_provider.dart';
import 'package:stories_by_parin/screens/event_screen.dart';

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
      appBar: AppBar(title: const Text('Projects')),

      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          /// if projects are loading show loader
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// if there is any error show error
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          /// show all projects list if no projects then show message
          if (provider.projects.isEmpty) {
            return Center(child: Text("No projects found"));
          }

          final projects = provider.projects;

          return ListView.builder(
            itemCount: projects.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {

              final project = projects[index];

              return ListTile(
                onTap: () {
                  /// Navigate to projects event screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EventScreen(project: project),));
                },
                title: Text(project.name),
                subtitle: Text("Project ID: ${project.id}"),
                trailing: Icon(Icons.chevron_right_rounded),
              );

            },
          );
        },
      ),
    );
  }
}
