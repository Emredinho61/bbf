import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final List<Item> _data = generateSettingsItems();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // removes the back arrow
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () {
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme();
              },
              icon: Theme.of(context).brightness == Brightness.dark
                  ? Image.asset('assets/icons/sun.png', height: 30)
                  : Image.asset('assets/icons/moon.png', height: 30),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildPanel(),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(title: Text(item.headerValue));
          },
          body: ListTile(title: Text(item.expandedValue)),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });
  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateSettingsItems() {
  return [
    Item(
      headerValue: 'Rechtliches',
      expandedValue: 'Alle rechtlichen Hinweise...',
    ),
    Item(
      headerValue: 'AGB',
      expandedValue: 'Unsere allgemeinen Geschäftsbedingungen...',
    ),
    Item(
      headerValue: 'Datenschutz',
      expandedValue: 'Informationen zum Datenschutz...',
    ),
    Item(
      headerValue: 'Über Uns',
      expandedValue: 'Mission, Vorstand, Kontakt, Spendenlinks, ...',
    ),
    Item(
      headerValue: 'Benutzerverwaltung',
      expandedValue: 'Hier kannst du Benutzer verwalten...',
    ),
    Item(headerValue: 'App-Version', expandedValue: 'Version 1.0.0'),
  ];
}
