import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config.dart';

/// Shows information about this app.
class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: defaultAppColor,
        elevation: 0.0,
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: defaultAppColor,
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 64.0),
                  Container(
                    width: 64.0,
                    height: 64.0,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image(image: AssetImage('images/logo.png')),
                    ),
                  ),
                  Text(
                    'Kanban',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: lightForeground,
                    ),
                  ),
                  if (snapshot.hasData)
                    Text(
                      ' ${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: lightForeground,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('A really basic, individual, Kanban board.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
