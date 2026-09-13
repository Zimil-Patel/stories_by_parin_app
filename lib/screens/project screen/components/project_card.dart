import 'package:flutter/material.dart';

import '../../../models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: ListTile(
        onTap: onTap,

        leading: CircleAvatar(
          child: const Icon(
            Icons.folder_outlined,
          ),
        ),

        title: Text(
          project.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          'Project ID: ${project.id}',
        ),

        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
      ),
    );
  }
}