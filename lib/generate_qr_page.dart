import 'dart:convert';

import 'package:akiba_scanner_qr/settings_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GenerateQrPage extends StatefulWidget {
  const GenerateQrPage({Key? key}) : super(key: key);
  @override
  _GenerateQrPageState createState() => _GenerateQrPageState();
}

class _GenerateQrPageState extends State<GenerateQrPage> {
  @override
  Widget build(BuildContext context) {
    return GenerateQrCard();
  }
}

class GenerateQrCard extends StatefulWidget {
  GenerateQrCard({Key? key}) : super(key: key);

  TextEditingController inputPathTextController = TextEditingController();
  TextEditingController outputPathTextController = TextEditingController();
  TextEditingController numOfQrCodesController = TextEditingController();


  @override
  _GenerateQrCardState createState() => _GenerateQrCardState();
}

class _GenerateQrCardState extends State<GenerateQrCard> {
  Map getGeneratePathController() {
    Map generatePathControllers = {
      'qrInputPath': widget.inputPathTextController,
      'qrOutputPath': widget.outputPathTextController,
      'numOfQr': widget.numOfQrCodesController
    };

    return generatePathControllers;
  }

  Future<String?> getQrInputPath(pathKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(pathKey);
  }

  Future<String?> retrieveQrInputPathHelper() async {
    widget.inputPathTextController.text =
        await getQrInputPath('qrInputPath') ?? "none";
    widget.outputPathTextController.text =
        await getQrInputPath('qrOutputPath') ?? "none";
  }

  @override
  Widget build(BuildContext context) {
    retrieveQrInputPathHelper();

    return Card(
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
                                controller: widget.inputPathTextController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide:
                                    const BorderSide(color: Colors.grey),
                                  ),
                                )),
                          ],
                        ))),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 10, 0),
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
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide:
                                    const BorderSide(color: Colors.grey),
                                  ),
                                )),
                          ],
                        ))),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 10, 0),
                  child: CupertinoButton(
                    onPressed: () async {
                      await pickDirectory(widget.outputPathTextController);
                    },
                    child: const Text('Browse'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const Text("Number of Qr Codes",
                          style: TextStyle(color: Color(0xffFCCFA8))),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: widget.numOfQrCodesController,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                //const Expanded(child: Spacer()),
                const Spacer(
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FloatingActionButton.extended(
                      onPressed: () {
                        sendData(serializeInputOutputJson(
                            widget.inputPathTextController.text,
                            widget.outputPathTextController.text,
                            widget.numOfQrCodesController.text));
                      },
                      backgroundColor: const Color(0xffFCCFA8),
                      label: const Text("Scan + Process")),
                )
              ],
            )
          ],
        ));
  }

  Map<String, String> serializeInputOutputJson(String input, String output,
      String qrNum) {
    Map<String, String> buildSendData = {
      "command": "generate_qr",
      "inputPath": input,
      "outputPath": output,
      "numOfQr": qrNum
    };

    print(buildSendData);

    return buildSendData;
  }

  void sendData(Map<String, String> commandInputOutputMap) {

    WebSocketChannel channel =
    WebSocketChannel.connect(Uri.parse("ws://localhost:49985"));

    if ( //widget.inputPathTextController.text.isNotEmpty &&
    widget.outputPathTextController.text.isNotEmpty &&
        widget.numOfQrCodesController.text.isNotEmpty) {
      channel.sink.add(jsonEncode(commandInputOutputMap));

      print("sent ${commandInputOutputMap}");
    }

   // channel.sink.close();
  }
}
