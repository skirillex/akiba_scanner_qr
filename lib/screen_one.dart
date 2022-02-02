import 'package:akiba_scanner_qr/generate_qr_page.dart';
import 'package:akiba_scanner_qr/scan_image_page.dart';
import 'package:akiba_scanner_qr/settings_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class ScreenOne extends StatefulWidget {
  ScreenOne({Key? key}) : super(key: key);

  @override
  _ScreenOneState createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  int _selectedIndex = 0;
  final padding = 8.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff28292E),
      body: Row(
        children: <Widget>[
          NavigationRail(
            minWidth: 56.0,
            groupAlignment: 1.0,
            backgroundColor: const Color(0xff2D3035),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            trailing: Column(
              children: <Widget>[
                const SizedBox(
                  height: 8,
                ),
                const SizedBox(
                  height: 108,
                ),
                RotatedBox(
                  quarterTurns: -1,
                  child: IconButton(
                    icon: const Icon(Icons.tune),
                    color: const Color(0xffFCCFA8),
                    onPressed: () {
                      settingsDialog(context);
                    },
                  ),
                )
              ],
            ),
            selectedLabelTextStyle: const TextStyle(
              color: Color(0xffFCCFA8),
              fontSize: 13,
              letterSpacing: 0.8,
            ),
            unselectedLabelTextStyle: const TextStyle(
              //color: Color(Colors.grey.value),
              color: Colors.white30,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
            destinations: [
              buildRotatedTextRailDestination("Scan + Process Images", padding,
                  const Icon(Icons.qr_code_scanner_sharp)),
              buildRotatedTextRailDestination(
                  "Generate QR Code", padding, const Icon(Icons.build_sharp)),
            ],
          ),
          // This is the main content.
          ContentSpace(_selectedIndex)
        ],
      ),
    );
  }
}

NavigationRailDestination buildRotatedTextRailDestination(
    String text, double padding, Icon iconImage) {
  return NavigationRailDestination(
    icon: iconImage, //const Icon(Icons.qr_code_scanner_sharp),
    label: Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: RotatedBox(
        quarterTurns: -1,
        child: Text(text),
      ),
    ),
  );
}

class ContentSpace extends StatelessWidget {
  final int _selectedIndex;

  ContentSpace(this._selectedIndex, {Key? key}) : super(key: key);

  final List<String> titles = [
    "Scan and Process Images",
    "Generate QR Code",
    "Settings",
  ];

  final List<Widget> pageViews = [ScanImagePage(), GenerateQrPage()];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 0, 0),
        child: MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 24,
              ),
              Text(titles[_selectedIndex],
                  style: Theme.of(context).textTheme.headline4),
              SizedBox(
                height: 24,
              ),
              IndexedStack(
                // keep state of pages and retain all data on them
                index: _selectedIndex,
                children: pageViews,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  final uri;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 0, 24, 24),
      child: Image.network(uri),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  const ImageCard(this.uri);
}
