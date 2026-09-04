import 'package:flutter/material.dart';

import '../../../models/person_model.dart';

class PersonCard extends StatelessWidget {
  final Person person;

  final VoidCallback onTap;

  const PersonCard({super.key, required this.person, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(12),

      child: Column(
        children: [
          // -------------------------------------------------
          // FACE IMAGE
          // -------------------------------------------------
          Expanded(
            child: ClipOval(
              child: Image.network(
                'http://127.0.0.1:8000/faces/${person.faceId}/image',

                width: 140,

                fit: BoxFit.cover,

                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.person, size: 50));
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // -------------------------------------------------
          // PHOTO COUNT
          // -------------------------------------------------
          Text(
            '${person.photoCount} photos',

            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
