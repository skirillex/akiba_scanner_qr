import 'dart:convert';

import 'package:akiba_scanner_qr/settings_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class ScanImagePage extends StatelessWidget {
  const ScanImagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScanCard(),
        //PythonSocketOutput()
      ],
    );
  }
}

// ignore: must_be_immutable
class ScanCard extends StatefulWidget {
  TextEditingController inputPathTextController = TextEditingController();
  TextEditingController outputPathTextController = TextEditingController();
  TextEditingController excelPathTextController = TextEditingController();

  WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse("ws://localhost:49985"));

  ScanCard({Key? key}) : super(key: key);

  @override
  _ScanCardState createState() => _ScanCardState();
}

class _ScanCardState extends State<ScanCard>
    with AutomaticKeepAliveClientMixin<ScanCard> {
  String? inputPath;

  Map getScanPathController() {
    Map scanPathControllers = {
      'inputPath': widget.inputPathTextController,
      'outputPath': widget.outputPathTextController,
      'excelPath': widget.excelPathTextController
    };

    return scanPathControllers;
  }

  /*
  Future<bool> saveInputPath() async {
    String text = widget.inputPathTextController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('inputPath', text);
  }

   */

  Future<String?> getInputPath(pathKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(pathKey);
  }

  Future<String?> retrieveInputPathHelper() async {
    widget.inputPathTextController.text =
        await getInputPath('inputPath') ?? "none";
    widget.outputPathTextController.text =
        await getInputPath('outputPath') ?? "none";
    widget.excelPathTextController.text =
        await getInputPath('excelPath') ?? "none";
  }

  @override
  Widget build(BuildContext context) {
    retrieveInputPathHelper();
    //retrieveDirPathHelper(getScanPathController());

    return Column(
      children: [
        Card(
            elevation: 4.0,
            margin: const EdgeInsets.fromLTRB(0, 0, 24, 24),
            color: const Color(0xff2D3035),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                const Text("Path to Input Folder",
                                    style: TextStyle(color: Color(0xffFCCFA8))),
                                TextFormField(
                                    //initialValue: "blah",
                                    controller: widget.inputPathTextController,
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
                          await pickDirectory(widget.inputPathTextController);
                        },
                        child: const Text('Browse'),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                const Text("Path to output Folder",
                                    style: TextStyle(color: Color(0xffFCCFA8))),
                                TextFormField(
                                    controller: widget.outputPathTextController,
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
                          /*
                          inputPath = await getInputPath();
                          setState(() {

                          });

                           */
                          await pickDirectory(widget.outputPathTextController);
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
                                    style: TextStyle(color: Color(0xffFCCFA8))),
                                TextFormField(
                                    controller: widget.excelPathTextController,
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
                      padding: const EdgeInsets.fromLTRB(5.0, 10.0, 50.0, 0.0),
                      child: CupertinoButton(
                        onPressed: () async {
                          await pickFile(widget.excelPathTextController);
                        },
                        child: const Text('Browse'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FloatingActionButton.extended(
                          onPressed: () {
                            sendData(serializeInputOutputJson(
                                widget.inputPathTextController.text,
                                widget.outputPathTextController.text,
                                widget.excelPathTextController.text));
                          },
                          backgroundColor: const Color(0xffFCCFA8),
                          label: const Text("Scan + Process")),
                    )
                  ],
                )
              ],
            )),
        PythonSocketOutput(widget.channel)
      ],
    );
  }

  Map<String, String> serializeInputOutputJson(
      String input, String output, String excel) {
    Map<String, String> buildSendData = {
      "command": "scan_and_sort",
      "inputPath": input,
      "outputPath": output,
      "excelPath": excel
    };

    print(buildSendData);

    return buildSendData;
  }

  void sendData(Map<String, String> commandInputOutputMap) {
    if (widget.inputPathTextController.text.isNotEmpty &&
        widget.outputPathTextController.text.isNotEmpty &&
        widget.excelPathTextController.text.isNotEmpty) {
      widget.channel.sink.add(jsonEncode(commandInputOutputMap));

      print("sent ${commandInputOutputMap}");
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class PythonSocketOutput extends StatefulWidget {
  const PythonSocketOutput(this.sockChannel, {Key? key}) : super(key: key);

  final WebSocketChannel sockChannel;

  @override
  State<StatefulWidget> createState() => _PythonSocketOutputState();
}

class _PythonSocketOutputState extends State<PythonSocketOutput> {
  WebSocketChannel get sockChannel => widget.sockChannel;

  @override
  Widget build(BuildContext context) {
    final messages = [];
    // ignore: prefer_const_constructors
    return Card(
        elevation: 4.0,
        margin: EdgeInsets.fromLTRB(0, 0, 24, 24),
        color: Color(0xff2D3035),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: SizedBox(
              height: 200.0,
              width: double.infinity,
              child: DecoratedBox(
                  decoration: const BoxDecoration(
                      //shape: BoxShape.rectangle,
                      //border: Border.all(width: 5.0, color: Colors.black),
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Align(
                          alignment: Alignment.bottomLeft,
                          child: StreamBuilder(
                            stream: widget.sockChannel.stream,
                            builder: (context, snapshot) {
                              messages.add(
                                  snapshot.hasData ? '${snapshot.data}' : '');
                              return ListView.builder(
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    var message = messages[index];
                                    print(messages);
                                    return Text(messages[index]);
                                  });
                            },
                          ))))),
        ));
  }
}
