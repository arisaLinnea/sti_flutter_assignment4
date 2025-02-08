import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final List<Widget> navbar = [
  const NavigationDestination(
      icon: Icon(Icons.home),
      selectedIcon: Icon(Icons.home, color: Colors.white),
      label: 'Home'),
  const NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.car),
      selectedIcon: FaIcon(FontAwesomeIcons.car, color: Colors.white),
      label: 'Vehicle'),
  const NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.squareParking),
      selectedIcon: FaIcon(FontAwesomeIcons.squareParking, color: Colors.white),
      label: 'Parkings')
];
