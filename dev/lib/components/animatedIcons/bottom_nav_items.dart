import 'rive_model.dart';

class NavItemModel {
  late final String title;
  late final RiveModel rive;

  NavItemModel({required this.title, required this.rive});
}

List<NavItemModel> bottomNavItems = [
  NavItemModel(
    title: 'Projekte',
    rive: RiveModel(
      src: 'assets/files/animated_icon_set_-_1_color.riv',
      artboard: "HOME",
      stateMachineName: 'HOME_interactivity',
    ),
  ),
  NavItemModel(
    title: 'Projekte',
    rive: RiveModel(
      src: 'assets/files/animated_icon_set_-_1_color.riv',
      artboard: "HOME",
      stateMachineName: 'HOME_interactivity',
    ),
  ),
  NavItemModel(
    title: 'Projekte',
    rive: RiveModel(
      src: 'assets/files/animated_icon_set_-_1_color.riv',
      artboard: "HOME",
      stateMachineName: 'HOME_interactivity',
    ),
  ),
  NavItemModel(
    title: 'Projekte',
    rive: RiveModel(
      src: 'assets/files/animated_icon_set_-_1_color.riv',
      artboard: "HOME",
      stateMachineName: 'HOME_interactivity',
    ),
  ),
  
];
