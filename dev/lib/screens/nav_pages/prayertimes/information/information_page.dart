import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information/add_information_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information/edit_information_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information/expaned_information_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final InformationService informationService = InformationService();
  final AuthService authService = AuthService();
  final UserService userService = UserService();

  List<Map<String, dynamic>> _allInformation = [];

  // only display certain Widgets if user is Admin
  bool isUserAdmin = false;
  bool showDeleteIcon = false;

  @override
  void initState() {
    super.initState();
    _loadInformation();
    checkUser();
  }

  Future<void> _loadInformation() async {
    final data = await informationService.getAllInformation();
    setState(() {
      _allInformation = data;
    });
  }

  // check if user is admin
  void checkUser() async {
    if (authService.currentUser == null) {
      return;
    }
    final value = await userService.checkIfUserIsAdmin();
    setState(() {
      isUserAdmin = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          if (isUserAdmin)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showDeleteIcon = !showDeleteIcon;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: BColors.secondary,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: BColors.primary),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.edit,
                          size: 35,
                          color: BColors.primary,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddInformationPage(),
                        ),
                      );

                      if (result == true) {
                        _loadInformation();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: BColors.secondary,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: BColors.primary),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.add,
                          size: 35,
                          color: BColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _allInformation.length,
              itemBuilder: (context, index) {
                final information = _allInformation[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
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
                                            builder: (_) =>
                                                ExpanedInformationPage(
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
                        if (showDeleteIcon)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final updatedInformation =
                                        await informationService
                                            .getAllInformation();
                                    setState(() {
                                      informationService.deleteInformation(
                                        information['Titel'],
                                      );
                                      _loadInformation();
                                    });
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UpdateInformaionPage(
                                          title: information['Titel'],
                                          text: information['Text'],
                                          expanded: information['Expanded'],
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      _loadInformation();
                                    }
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
