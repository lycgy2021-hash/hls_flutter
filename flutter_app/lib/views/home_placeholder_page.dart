import 'package:flutter/material.dart';

import 'package:flutter_app/config/app_config.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Migration Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('M0 Placeholder Home'),
            const SizedBox(height: 12),
            Chip(label: Text('env: ${AppConfig.envLabel}')),
          ],
        ),
      ),
    );
  }
}
