import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:preferences/preference_page.dart';
import 'package:preferences/preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GetIngredientsAvailableRequest {
  Map<String, dynamic> toJson() => {
        'type': 'getLiquids',
      };
}

class SetIngredientsAvailableRequest {
  final List<String> optics;
  final List<String> pumps;

  SetIngredientsAvailableRequest(this.optics, this.pumps);

  Map<String, dynamic> toJson() =>
      {
        'type': 'setIngredientsAvailable',
        'available': {
          'optics': this.optics,
          'pumps': this.pumps,
        }
      };
}

class SettingsPage extends StatefulWidget {
  final WebSocketChannel channel;
  final int numOptics = 4;
  final int numPumps = 8;

  SettingsPage({Key key, this.channel}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();

  getIngredientsAvailable() {
    debugPrint("Getting liquids");
    channel.sink.add(json.encode(GetIngredientsAvailableRequest()));
  }

  setIngredientsAvailable() {
    PrefService.getString('user_description', ignoreCache: true);
    var optics = PrefService.getKeys()
        .map((key) => key.replaceAll('pref_', ''))
        .where((element) => element.contains('optic_'))
        .map((key) => PrefService.getString(key))
        .toList();

    var pumps = PrefService.getKeys()
        .map((key) => key.replaceAll('pref_', ''))
        .where((element) => element.contains('pump_'))
        .map((key) => PrefService.getString(key))
        .toList();

    debugPrint("Setting liquids");
    channel.sink.add(
        json.encode(SetIngredientsAvailableRequest(optics, pumps)));
  }
}

class _SettingsPageState extends State<SettingsPage> {

  // Build the option ui dialog
  Widget buildOptionDialog(int num, String type, List<String> ingredients) {
    List<Widget> options = ingredients.map<Widget>((e) =>
        RadioPreference(e, e, type + '_' + num.toString())
    ).toList();
    return PreferenceDialogLink(
      type + ' ' + num.toString(),
      dialog: PreferenceDialog(
        options,
        title: type + ' ' + num.toString(),
        cancelText: 'Close',
      ),
    );
  }

  // Build the option ui dialog
  List<Widget> buildOptionDialogs(int count, String type,
      List<String> ingredients) {
    return new List.generate(
        count, (index) => buildOptionDialog(index + 1, type, ingredients));
  }

  @override
  Widget build(BuildContext context) {
    this.widget.getIngredientsAvailable(); // Load available liquids
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: PreferencePage([
        // PreferenceTitle('General'),
        // DropdownPreference(
        //   'Start Page',
        //   'start_page',
        //   defaultVal: 'Timeline',
        //   values: ['Posts', 'Timeline', 'Private Messages'],
        // ),
        // DropdownPreference<int>(
        //   'Number of items',
        //   'items_count',
        //   defaultVal: 2,
        //   displayValues: ['One', 'Two', 'Three', 'Four'],
        //   values: [1, 2, 3, 4],
        // ),
        PreferenceTitle('Liquids'),
        PreferencePageLink(
          'Optics',
          trailing: Icon(Icons.keyboard_arrow_right),
          page: PreferencePage([
            PreferenceTitle('Optics'),
            SwitchPreference(
              'Optics Enabled',
              'notification_newpost_friend',
              defaultVal: true,
            ),
            PreferenceTitle('Channels'),
            ...buildOptionDialogs(
                this.widget.numOptics, 'optic', ['apple', 'orange', 'vodka'])
          ]),
        ),
        PreferencePageLink(
          'Pumps',
          trailing: Icon(Icons.keyboard_arrow_right),
          page: PreferencePage([
            PreferenceTitle('Pumps'),
            SwitchPreference(
              'Pumps Enabled',
              'notification_newpost_friend',
              defaultVal: true,
            ),
            PreferenceTitle('Channels'),
            ...buildOptionDialogs(
                this.widget.numPumps, 'pump', ['apple', 'orange', 'vodka'])
          ]),
        ),
        PreferenceTitle('Connection'),
        TextFieldPreference(
          'Server IP',
          'server_ip',
        ),
        RaisedButton(
          onPressed: this.widget.setIngredientsAvailable,
          color: Color.fromRGBO(58, 66, 86, 1.0),
          child: Text("Save", style: TextStyle(color: Colors.white)),
        )
        // TextFieldPreference('E-Mail', 'user_email',
        //     defaultVal: 'email@example.com', validator: (str) {
        //       return null;
        //     }),
        // PreferenceText(
        //   PrefService.getString('user_description', ignoreCache: true) ?? '',
        //   style: TextStyle(color: Colors.grey),
        // ),
        // PreferenceDialogLink(
        //   'Edit description',
        //   dialog: PreferenceDialog(
        //     [
        //       TextFieldPreference(
        //         'Description',
        //         'user_description',
        //         padding: const EdgeInsets.only(top: 8.0),
        //         autofocus: true,
        //         maxLines: 2,
        //       )
        //     ],
        //     title: 'Edit description',
        //     cancelText: 'Cancel',
        //     submitText: 'Save',
        //     onlySaveOnSubmit: true,
        //   ),
        //   onPop: () => setState(() {}),
        // ),
        // PreferenceTitle('Content'),
        // PreferenceDialogLink(
        //   'Content Types',
        //   dialog: PreferenceDialog(
        //     [
        //       CheckboxPreference('Text', 'content_show_text'),
        //       CheckboxPreference('Images', 'content_show_image'),
        //       CheckboxPreference('Music', 'content_show_audio')
        //     ],
        //     title: 'Enabled Content Types',
        //     cancelText: 'Cancel',
        //     submitText: 'Save',
        //     onlySaveOnSubmit: true,
        //   ),
        // ),
        // PreferenceTitle('More Dialogs'),
        // PreferenceDialogLink(
        //   'Android\'s "ListPreference"',
        //   dialog: PreferenceDialog(
        //     [
        //       RadioPreference(
        //           'Select me!', 'select_1', 'android_listpref_selected'),
        //       RadioPreference(
        //           'Hello World!', 'select_2', 'android_listpref_selected'),
        //       RadioPreference('Test', 'select_3', 'android_listpref_selected'),
        //     ],
        //     title: 'Select an option',
        //     cancelText: 'Cancel',
        //     submitText: 'Save',
        //     onlySaveOnSubmit: true,
        //   ),
        // ),
        // PreferenceDialogLink(
        //   'Android\'s "ListPreference" with autosave',
        //   dialog: PreferenceDialog(
        //     [
        //       RadioPreference(
        //           'Select me!', 'select_1', 'android_listpref_auto_selected'),
        //       RadioPreference(
        //           'Hello World!', 'select_2', 'android_listpref_auto_selected'),
        //       RadioPreference(
        //           'Test', 'select_3', 'android_listpref_auto_selected'),
        //     ],
        //     title: 'Select an option',
        //     cancelText: 'Close',
        //   ),
        // ),
        // PreferenceDialogLink(
        //   'Android\'s "MultiSelectListPreference"',
        //   dialog: PreferenceDialog(
        //     [
        //       CheckboxPreference('A enabled', 'android_multilistpref_a'),
        //       CheckboxPreference('B enabled', 'android_multilistpref_b'),
        //       CheckboxPreference('C enabled', 'android_multilistpref_c'),
        //     ],
        //     title: 'Select multiple options',
        //     cancelText: 'Cancel',
        //     submitText: 'Save',
        //     onlySaveOnSubmit: true,
        //   ),
        // ),
        // PreferenceHider([
        //   PreferenceTitle('Experimental'),
        //   SwitchPreference(
        //     'Show Operating System',
        //     'exp_showos',
        //     desc: 'This option shows the users operating system in his profile',
        //   )
        // ], '!advanced_enabled'), // Use ! to get reversed boolean values
        // PreferenceTitle('Advanced'),
        // CheckboxPreference(
        //   'Enable Advanced Features',
        //   'advanced_enabled',
        //   onChange: () {
        //     setState(() {});
        //   },
        //   onDisable: () {
        //     PrefService.setBool('exp_showos', false);
        //   },
        // )
      ]),
    );
  }
}
