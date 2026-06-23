import 'package:app/screens/222_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/app_settings.dart';
import 'package:app/app_locale.dart';

class Settings extends StatefulWidget {
  final GlobalKey<RecordPageState> recordKey;
  const Settings({
    super.key,
    final firstStart,
    final wcaId,
    required this.recordKey,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _wcaIdController = TextEditingController(text: AppSettings.wcaId ?? '');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue,
      child: Center(
        child: Column(
          children: [
            Text(
              AppLocale.t(context, 'settings'),
              style: TextStyle(
                // color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SwitchListTile(
              title: Text(AppLocale.t(context, 'toggle_shake')),
              value: AppSettings.toggleShake,
              onChanged: (value) {
                setState(() => AppSettings.toggleShake = value);
              },
            ),
            ListTile(
              title: Text('WCA-ID:'),
              trailing: SizedBox(
                width: 200,
                child: TextField(
                  controller: _wcaIdController,
                  onChanged: (val) {
                    AppSettings.wcaId = val;
                    widget.recordKey.currentState?.setState(() {});
                  },
                  decoration: InputDecoration(hintText: '2020MEIE01'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
