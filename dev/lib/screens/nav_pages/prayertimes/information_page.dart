import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/expaned_information.dart';
import 'package:flutter/material.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final InformationService informationService = InformationService();
  List<Map<String, dynamic>> _allInformation = [];

  @override
  void initState() {
    super.initState();
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    final data = await informationService.getAllInformation();
    setState(() {
      _allInformation = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _allInformation.length,
      itemBuilder: (context, index) {
        final information = _allInformation[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(information['Titel'] ?? ''),
                    ),
                    subtitle: Text(information['Text'] ?? ''),
                  ),
                ),
                information['Expanded'].isEmpty
                    ? Text('')
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExpanedInformationPage(
                                  information: information,
                                ),
                              ),
                            );
                          },
                          child: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
