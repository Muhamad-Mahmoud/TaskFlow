import 'package:flutter/material.dart';

class TaskSearchDelegate extends SearchDelegate<String?> {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) return const SizedBox.shrink();

    // Mock search results
    final results = [
      'Revamp Design System strategy',
      'Onboarding flow refinement',
    ].where((task) => task.toLowerCase().contains(query.toLowerCase())).toList();

    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No results found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (ctx, i) {
        return ListTile(
          title: Text(results[i]),
          leading: const Icon(Icons.check_circle_outline),
          onTap: () {
            close(context, results[i]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Type to search for tasks...'),
      );
    }
    return buildResults(context);
  }
}

