import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextEditingController settingsScanInputPathTextController =
    TextEditingController();

TextEditingController settingsScanOutputPathTextController =
    TextEditingController();

TextEditingController settingsScanExcelTextController = TextEditingController();

TextEditingController settingsQrInputPathTextController =
    TextEditingController();

TextEditingController settingsQrOutputPathTextController =
    TextEditingController();

Map pathControllers = {
  'inputPath': settingsScanInputPathTextController,
  'outputPath': settingsScanOutputPathTextController,
  'excelPath': settingsScanExcelTextController,
  'qrOutputPath': settingsQrOutputPathTextController,
  'qrInputPath': settingsQrInputPathTextController
};

Future<String> pickDirectory(TextEditingController textController) async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory == null) {
    return "null";
  }

  textController.text = selectedDirectory;

  return selectedDirectory;
}

Future<String?> pickFile(TextEditingController textController) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    textController.text = result.files.single.path!;
    return result.files.single.path;
  } else {
    // User canceled the picker
  }
}

Future<bool> saveDirPaths(prefsKey, controller) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(prefsKey, controller.text);
}

Future<String?> getDirPaths(prefsKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(prefsKey);
}

Future<String?> retrieveDirPathHelper(Map controllerMap) async {
  for (var path in controllerMap.keys) {
    pathControllers[path].text = await getDirPaths(path) ?? "none";
  }

  //widget.inputPathTextController.text = await getDirPaths() ?? "none";
}

Future<void> settingsDialog(context) async {
  retrieveDirPathHelper(pathControllers);

  return showDialog(
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(40),
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                      child: Text(
                    "Default Settings",
                    style: TextStyle(color: Color(0xffFCCFA8), fontSize: 30),
                  )),
                  const Text(
                    "Scan + Process Images",
                    style: TextStyle(color: Color(0xffFCCFA8), fontSize: 15),
                  ),
                  const Divider(color: Colors.grey),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  const Text("Path to Input Folder",
                                      style:
                                          TextStyle(color: Color(0xffFCCFA8))),
                                  TextFormField(
                                      controller:
                                          settingsScanInputPathTextController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                      )),
                                ],
                              ))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                        child: CupertinoButton(
                          onPressed: () async {
                            await pickDirectory(
                                settingsScanInputPathTextController);
                          },
                          child: const Text('Browse'),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  const Text("Path to Output Folder",
                                      style:
                                          TextStyle(color: Color(0xffFCCFA8))),
                                  TextFormField(
                                      controller:
                                          settingsScanOutputPathTextController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                      )),
                                ],
                              ))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                        child: CupertinoButton(
                          onPressed: () async {
                            await pickDirectory(
                                settingsScanOutputPathTextController);
                          },
                          child: const Text('Browse'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  const Text("Path to Excel File",
                                      style:
                                          TextStyle(color: Color(0xffFCCFA8))),
                                  TextFormField(
                                      controller:
                                          settingsScanExcelTextController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                      )),
                                ],
                              ))),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CupertinoButton(
                          onPressed: () async {
                            await pickFile(settingsScanExcelTextController);
                          },
                          child: const Text('Browse'),
                        ),
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: Text(
                      "Generate QR Code",
                      style: TextStyle(color: Color(0xffFCCFA8), fontSize: 15),
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  const Text("Path to Input Folder",
                                      style:
                                          TextStyle(color: Color(0xffFCCFA8))),
                                  TextFormField(
                                      controller:
                                          settingsQrInputPathTextController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                      )),
                                ],
                              ))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                        child: CupertinoButton(
                          onPressed: () async {
                            await pickDirectory(
                                settingsQrInputPathTextController);
                          },
                          child: const Text('Browse'),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  const Text("Path to Output Folder",
                                      style:
                                          TextStyle(color: Color(0xffFCCFA8))),
                                  TextFormField(
                                      controller:
                                          settingsQrOutputPathTextController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                      )),
                                ],
                              ))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                        child: CupertinoButton(
                          onPressed: () async {
                            await pickDirectory(
                                settingsQrOutputPathTextController);
                          },
                          child: const Text('Browse'),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FloatingActionButton.extended(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop("dialog");
                              },
                              label: const Text("Cancel")),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FloatingActionButton.extended(
                              onPressed: () async {
                                for (var path in pathControllers.keys) {
                                  await saveDirPaths(
                                      path, pathControllers[path]);
                                }

                                Navigator.of(context, rootNavigator: true)
                                    .pop("dialog");

                                // TODO add toast popup saying successfully saved
                              },
                              label: const Text("Save")),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      context: context);
}
