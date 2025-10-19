import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information_tab/add_information_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information_tab/edit_information_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information_tab/expanded_information_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:bbf_app/utils/helper/information_page_helper.dart';
import 'package:flutter/material.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final InformationService informationService = InformationService();
  final InformationPageHelper informationPageHelper = InformationPageHelper();
  final AuthService authService = AuthService();
  final UserService userService = UserService();
  final CheckUserHelper checkUserHelper = CheckUserHelper();

  List<Map<String, dynamic>> _allInformation = [];

  late bool isUserAdmin;
  bool editMode = false;

  @override
  void initState() {
    super.initState();
    isUserAdmin = checkUserHelper.getUsersPrefs();
    _initPage();
  }

  Future<void> _initPage() async {
    await _loadInformation();
    await userOpenedInformationPage();
    checkUser();
  }

  // if user opens information page, this means that there are currently no new information unseen
  Future<void> userOpenedInformationPage() async {
    await informationPageHelper.setTotalInformationNumber(
      _allInformation.length,
    );
  }

  // loads all Information from backend
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
      if (value != isUserAdmin) {
        checkUserHelper.setCheckUsersPrefs(value);
        isUserAdmin = value;
      }
    });
  }

  // Displays all Information as Cards below each other
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // if user is Admin, user can either edit Information card or add a new one
          if (isUserAdmin) _buildAdminActionRow(context),

          // building all the Information Cards
          Expanded(
            child: ListView.builder(
              itemCount: _allInformation.length,
              itemBuilder: (context, index) {
                final information = _allInformation[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildInformationCard(information, context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Information Card
  Card _buildInformationCard(
    Map<String, dynamic> information,
    BuildContext context,
  ) {
    return Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text which is displayed on the Information Card
              _informationTextContent(information),

              // Displays an Icon for showing more detailed information, if it exists
              information['Expanded'].isEmpty
                  ? Text('')
                  : _routeToExpandedInformationPage(context, information),
            ],
          ),

          // if edit mode is active, delete and edit Icons are displayed
          if (editMode) _editInformationRow(information, context),
        ],
      ),
    );
  }

  // remove and edit information card
  Padding _editInformationRow(
    Map<String, dynamic> information,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _deleteInformation(information),
          _routeToEditInformationPage(context, information),
        ],
      ),
    );
  }

  // if admin wants to edit Card, a new Page is opended for editing
  GestureDetector _routeToEditInformationPage(
    BuildContext context,
    Map<String, dynamic> information,
  ) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UpdateInformationPage(
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
      child: Icon(Icons.edit, color: Colors.blue, size: 30),
    );
  }

  // deleting Information Card..
  GestureDetector _deleteInformation(Map<String, dynamic> information) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          informationService.deleteInformation(information['Titel']);
          _loadInformation();
        });
      },
      child: Icon(Icons.delete, color: Colors.red, size: 30),
    );
  }

  // if information contains details, this will lead the user to a new page with all the information details
  Padding _routeToExpandedInformationPage(
    BuildContext context,
    Map<String, dynamic> information,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExpanedInformationPage(information: information),
            ),
          );
        },
        child: Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  // information (excluding the details) will be displayed on information card
  Expanded _informationTextContent(Map<String, dynamic> information) {
    return Expanded(
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(information['Titel'] ?? ''),
        ),
        subtitle: Text(information['Text'] ?? ''),
      ),
    );
  }

  Padding _buildAdminActionRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [_editInformationIcon(), _addInformationIcon(context)],
      ),
    );
  }

  GestureDetector _addInformationIcon(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddInformationPage()),
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
          child: Icon(Icons.add, size: 35, color: BColors.primary),
        ),
      ),
    );
  }

  GestureDetector _editInformationIcon() {
    return GestureDetector(
      onTap: () {
        setState(() {
          editMode = !editMode;
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
          child: Icon(Icons.edit, size: 35, color: BColors.primary),
        ),
      ),
    );
  }
}
