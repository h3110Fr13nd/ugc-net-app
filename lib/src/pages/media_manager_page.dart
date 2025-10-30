import 'package:flutter/material.dart';
import 'page_template.dart';

class MediaManagerPage extends StatelessWidget {
  const MediaManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Media Manager',
      subtitle: 'Upload, search and attach media to content',
      children: [
        ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_file), label: const Text('Upload')),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            8,
            (i) => SizedBox(
              width: 140,
              child: Card(
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(color: Colors.grey.shade800, child: const Icon(Icons.image, size: 48)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
