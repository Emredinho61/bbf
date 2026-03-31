import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information_tab/add_information_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information_tab/edit_information_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information_tab/expanded_information_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:bbf_app/utils/helper/information_page_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.image,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  String? image;
  bool isExpanded;
}

List<Item> generateItems(List<Map<String, dynamic>> data) {
  return data.map((element) {
    return Item(
      headerValue: element["Titel"],
      expandedValue: element["Text"],
      image: element['Image'],
    );
  }).toList();
}

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
  List<Item> _data = [];

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
    if (!mounted) return;
    setState(() {
      _allInformation = data;
      _data = generateItems(_allInformation);
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              if (isUserAdmin) _buildAdminActionRow(context),
              ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _data[index].isExpanded = isExpanded;
                  });
                },
                children: _data.map<ExpansionPanel>((Item item) {
                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(item.headerValue),
                          trailing: isUserAdmin
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _data.removeWhere(
                                        (currentItem) => currentItem == item,
                                      );
                                    });
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                    body: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          item.expandedValue.isEmpty
                              ? SizedBox.shrink()
                              : Text(item.expandedValue),
                          const SizedBox(height: 12),
                          (item.image ?? '').isNotEmpty
                              ? AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: CachedNetworkImage(
                                    imageUrl: item.image ?? '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Skeletonizer(
                                      enabled: true,
                                      child: SizedBox(height: 100, width: 100),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                    isExpanded: item.isExpanded,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
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
          // _routeToEditInformationPage(context, information),
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
              id: information['id'],
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
          informationService.deleteInformation(information['id']);
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
