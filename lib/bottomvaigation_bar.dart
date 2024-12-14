import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:wastepickup_app/screens/address_enter_page.dart';
import 'package:wastepickup_app/screens/profile_page.dart';

import 'screens/home_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  List Screens = [HomePage(), const AddressEnterPage(), const ProfilePage()];
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white70,
      bottomNavigationBar: CurvedNavigationBar(
        height: 50,
        index: _selectedIndex,
        backgroundColor: Colors.transparent,
        items:   const [
          Icon(
            Icons.home,
            size: 30,
            color: Colors.green,
          ),
          Icon(
            Icons.add,
            size: 32,
            color: Colors.green,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: Colors.green,
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: Screens[_selectedIndex],
    );
  }
}
