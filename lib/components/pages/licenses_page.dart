import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/utility/string_extensions.dart';
import '../../oss_licenses.dart';

class LicencesPage extends StatelessWidget {
  const LicencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: const Text('Licences'),
      body: ListView.builder(
        itemCount: ossLicenses.length,
        itemBuilder: (_, index) {
          return ExpansionTile(
            title: Text(
              ossLicenses[index].name.toBeginningOfSentenceCase(),
            ),
            subtitle: Text(ossLicenses[index].description),
            children: [
              Divider(
                color: Theme.of(context).colorScheme.primaryContainer,
                indent: 12,
                endIndent: 12,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: MarkdownBody(data: ossLicenses[index].license!),
              ),
            ],
          );
        },
      ),
    );
  }
}
