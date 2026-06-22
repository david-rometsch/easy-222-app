import 'package:flutter/material.dart';
import 'package:app/get_api.dart';
import 'package:app/app_locale.dart';
import 'package:app/app_settings.dart';

class RecordPage extends StatefulWidget {
  final VoidCallback onGoToEasyTwo;
  final VoidCallback onGoToSettings;
  const RecordPage({
    super.key,
    required this.onGoToEasyTwo,
    required this.onGoToSettings,
  });

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  Map<String, dynamic> record = {};
  bool _loading = true;

  String _formatRecord(dynamic best) {
    if (best == null) return AppLocale.t(context, 'no_value_found');
    return '${(best / 100).toStringAsFixed(2)}s';
  }

  @override
  void initState() {
    super.initState();
    _getWcaData();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('WCA-ID: ${AppSettings.wcaId}'),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: widget.onGoToSettings,
                child: Text(AppLocale.t(context, 'set_wcaid')),
              ),
            ],
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

  void _getWcaData() async {
    try {
      final data = await Api.getWcaData(AppSettings.wcaId);

      setState(() {
        record = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection')),
      );
    }
  }
}
