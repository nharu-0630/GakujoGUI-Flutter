import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () => launchUrlString(
          'https://gakujo.shizuoka.ac.jp/portal/',
          mode: LaunchMode.externalApplication,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Icon(
                    Icons.school,
                    size: 24.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LiveCampus',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '最終更新日時: ',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
