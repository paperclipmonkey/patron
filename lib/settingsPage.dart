import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:preferences/preference_page.dart';
import 'package:preferences/preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GetLiquidsRequest {
  Map<String, dynamic> toJson() => {
        'type': 'getLiquids',
      };
}

class SetLiquidsRequest {
  Map<String, dynamic> toJson() => {
        'type': 'setLiquids',
      };
}

class SettingsPage extends StatefulWidget {
  final WebSocketChannel channel;

  SettingsPage({Key key, this.channel}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();

  getLiquids() {
    debugPrint("Getting liquids");
    channel.sink.add(json.encode(GetLiquidsRequest()));
  }

  setLiquids() {
    debugPrint("Setting liquids");
    channel.sink.add(json.encode(SetLiquidsRequest()));
  }
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    this.widget.getLiquids(); // Load available liquids
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
            TextFieldPreference(
              'Channel 0',
              'channel0',
            ),
            TextFieldPreference(
              'Channel 1',
              'channel1',
            ),
            TextFieldPreference(
              'Channel 2',
              'channel2',
            ),
            TextFieldPreference(
              'Channel 3',
              'channel3',
            ),
            TextFieldPreference(
              'Channel 4',
              'channel4',
            ),
            TextFieldPreference(
              'Channel 5',
              'channel5',
            ),
            TextFieldPreference(
              'Channel 6',
              'channel6',
            ),
            TextFieldPreference(
              'Channel 7',
              'channel7',
            ),
          ]),
        ),
        PreferencePageLink(
          'Pumps',
          trailing: Icon(Icons.keyboard_arrow_right),
          page: PreferencePage([
            PreferenceTitle('New Posts'),
            SwitchPreference(
              'New Posts from Friends',
              'notification_newpost_friend',
              defaultVal: true,
            ),
            PreferenceTitle('Private Messages'),
            SwitchPreference(
              'Private Messages from Friends',
              'notification_pm_friend',
              defaultVal: true,
            ),
            SwitchPreference(
              'Private Messages from Strangers',
              'notification_pm_stranger',
              onEnable: () async {
                // Write something in Firestore or send a request
                await Future.delayed(Duration(seconds: 1));

                print('Enabled Notifications for PMs from Strangers!');
              },
              onDisable: () async {
                // Write something in Firestore or send a request
                await Future.delayed(Duration(seconds: 1));

                // No Connection? No Problem! Just throw an Exception with your custom message...
                throw Exception('No Connection');

                // Disabled Notifications for PMs from Strangers!
              },
            ),
          ]),
        ),
        PreferenceTitle('Connection'),
        TextFieldPreference(
          'Server IP',
          'server_ip',
        ),
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
