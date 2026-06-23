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
  State<RecordPage> createState() => RecordPageState();
}

class RecordPageState extends State<RecordPage> {
  Map<String, dynamic> record = {};
  bool _loading = true;
  final _blueTextStyle = TextStyle(
    color: Colors.blue,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

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
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${AppLocale.t(context, '222_record_display')}',
              style: _blueTextStyle,
            ),
            Text(
              'single: ${_formatRecord(record['personal_records']?['222']?['single']?['best'])}',
              style: _blueTextStyle,
            ),
            Text(
              'ao5: ${_formatRecord(record['personal_records']?['222']?['average']?['best'])}',
              style: _blueTextStyle,
            ),
            SizedBox(height: 32),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocale.t(context, 'no_inet'))));
    }
  }
}
