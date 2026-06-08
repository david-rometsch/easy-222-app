import 'package:flutter/material.dart';
import 'package:app/get_api.dart';
import 'package:app/app_locale.dart';

class RecordPage extends StatefulWidget {
  final VoidCallback onGoToEasyTwo;
  const RecordPage({super.key, required this.onGoToEasyTwo});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  Map<String, dynamic> record = {};
  bool _loading = true;

  String _formatRecord(dynamic best) {
    if (best == null) return 'no value found';
    return '${(best / 100).toStringAsFixed(2)}s';
  }

  @override
  void initState() {
    super.initState();
    Api.getWcaData('2019ROME03').then((data) {
      setState(() {
        record = data ?? {};
        _loading = false;
      });
    });
  }

  // final record = best != null ? '${(best / 100).toStringAsFixed(2)}s' : 'not defined';
  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Container(
      // color: Colors.cyan,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${AppLocale.t(context, '222_record_display')}${_formatRecord(record['personal_records']?['222']?['single']?['best'])}',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onGoToEasyTwo,
            child: Text(AppLocale.t(context, 'train_more')),
          ),
        ],
      ),
    );
  }
}
