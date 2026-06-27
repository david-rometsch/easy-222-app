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
  // null = no error; locale key otherwise
  String? _errorKey;

  String _formatRecord(dynamic best) {
    if (best == null) return AppLocale.t(context, 'no_value_found');
    return '${(best / 100).toStringAsFixed(2)}s';
  }

  @override
  void initState() {
    super.initState();
    _getWcaData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_errorKey != null) return _buildErrorState(context);
    final single = _formatRecord(record['personal_records']?['222']?['single']?['best']);
    final ao5 = _formatRecord(record['personal_records']?['222']?['average']?['best']);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocale.t(context, '222_record_display'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          _recordTile('Single', single, context),
          const SizedBox(height: 12),
          _recordTile('Ao5', ao5, context),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'WCA-ID: ${AppSettings.wcaId}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: widget.onGoToSettings,
                child: Text(AppLocale.t(context, 'set_wcaid')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.onGoToEasyTwo,
            child: Text(AppLocale.t(context, 'train_more')),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            AppLocale.t(context, _errorKey!),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: widget.onGoToSettings,
                child: Text(AppLocale.t(context, 'set_wcaid')),
              ),
              FilledButton(
                onPressed: widget.onGoToEasyTwo,
                child: Text(AppLocale.t(context, 'train_more')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recordTile(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  void _getWcaData() async {
    try {
      final data = await Api.getWcaData(AppSettings.wcaId);
      setState(() {
        record = data;
        _errorKey = null;
        _loading = false;
      });
    } on ApiNotFoundException {
      setState(() {
        _errorKey = 'wca_not_found';
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _errorKey = 'no_inet';
        _loading = false;
      });
    }
  }
}
