import 'package:flutter/material.dart';
import 'package:app/get_api.dart';
import 'package:app/app_locale.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key, required this.title, required this.goToEasyTwo});
  final String title;
  final VoidCallback goToEasyTwo;
  

  @override
  Widget build(BuildContext context) {
    final best = wcaData['personal_records']?['222']?['single']?['best'];
    final record = best != null ? '${(best / 100).toStringAsFixed(2)}s' : 'not defined';

    return Container(
      // color: Colors.cyan,
      alignment: Alignment.center, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocale.t(context, '222_record_display') + record,
            style: Theme.of(context).textTheme.displayLarge
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: goToEasyTwo,
            child: Text(AppLocale.t(context, 'train_more'))
          )
        ]
      ),
    );
  }
}
