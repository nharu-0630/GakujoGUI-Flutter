import 'package:flutter/material.dart';
import 'package:gakujo_task/provide.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var settings = context.watch<ApiProvider>().api.settings;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Icon(
                      Icons.school_rounded,
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
                        Row(
                          children: [
                            Text(
                              '最終ログイン',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              (settings.lastLoginTime == null
                                  ? ''
                                  : DateFormat('yyyy/MM/dd HH:mm', 'ja')
                                      .format(settings.lastLoginTime)),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: () => launchUrlString(
                  'https://gakujo.shizuoka.ac.jp/portal/',
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
