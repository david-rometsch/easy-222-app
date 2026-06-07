import 'package:flutter/material.dart';
import 'package:app/get_api.dart';

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
            'My actual 2x2 record: $record',
            style: Theme.of(context).textTheme.displayLarge
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: goToEasyTwo,
            child: Text('Train More'))
        ],
      ),
    );
  }
}
