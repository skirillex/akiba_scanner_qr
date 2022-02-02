import 'dart:convert';
import 'dart:io';

import 'package:akiba_scanner_qr/settings_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:progress_state_button/progress_button.dart';

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

int portNumber = 49985;

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

    portNumber = int.parse(await getQrInputPath('port') ?? "49985");
  }

  ButtonState stateOnlyText = ButtonState.idle;
  @override
  Widget build(BuildContext context) {
    retrieveQrInputPathHelper();
    print("generate qr page port:");
    print(portNumber);
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
                const Spacer(),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        width: 200,
                        child: ProgressButton.icon(
                          textStyle: TextStyle(color: Colors.black),
                          iconedButtons: {
                            ButtonState.idle: IconedButton(
                                text: "Generate QR Codes",
                                icon: Icon(
                                  Icons.build_rounded,
                                  color: Colors.black,
                                ),
                                color: const Color(0xffFCCFA8)),
                            ButtonState.loading: IconedButton(
                                text: "Loading", color: Colors.brown.shade300),
                            ButtonState.fail: IconedButton(
                                text: "Failed",
                                icon: Icon(Icons.cancel, color: Colors.white),
                                color: Colors.red.shade300),
                            ButtonState.success: IconedButton(
                                text: "Success",
                                icon: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                color: Colors.green.shade400)
                          },
                          onPressed: () async {
                            setState(() {
                              stateOnlyText = ButtonState.loading;
                            });

                            await startServerSendData(
                              serializeInputOutputJson(
                                  widget.inputPathTextController.text,
                                  widget.outputPathTextController.text,
                                  widget.numOfQrCodesController.text),
                            );

                            setState(() {
                              stateOnlyText = ButtonState.idle;
                            });
                          },
                          state: stateOnlyText,
                        )))
              ],
            )
          ],
        ));
  }

  startServerSendData(Map<String, String> commandInputOutputMap) async {
    await startQrServer();
    await sendData(commandInputOutputMap);
  }

  startQrServer() async {
    print("async process starting");

    String mainPath = Platform.resolvedExecutable;
    print("mainpath");
    print(mainPath);
    print(mainPath.lastIndexOf('/'));
    mainPath = mainPath.substring(0, mainPath.lastIndexOf('/'));
    mainPath = mainPath.substring(0, mainPath.lastIndexOf('/'));

    print("portnumber in start server $portNumber");

    Process result = await Process.start(
      'open',
      [
        '$mainPath/Resources/Akiba_QR_Engine.app/',
      ],
      environment: {'AKIBA_PORT': '$portNumber'},
      runInShell: true,
    );

    return result;
  }

  Map<String, String> serializeInputOutputJson(
      String input, String output, String qrNum) {
    Map<String, String> buildSendData = {
      "command": "generate_qr",
      "inputPath": input,
      "outputPath": output,
      "numOfQr": qrNum
    };

    print(buildSendData);

    return buildSendData;
  }

  sendData(Map<String, String> commandInputOutputMap) async {
    await Future.delayed(Duration(seconds: 6), () async {
      if (widget.outputPathTextController.text.isNotEmpty &&
          widget.numOfQrCodesController.text.isNotEmpty) {
        //setState(() {
        //  WebSocketChannel channel =
        //      WebSocketChannel.connect(Uri.parse("ws://localhost:$portNumber"));
        //});

        WebSocketChannel channel =
            WebSocketChannel.connect(Uri.parse("ws://localhost:$portNumber"));

        channel.sink.add(jsonEncode(commandInputOutputMap));

        print("sent ${commandInputOutputMap}");
      }
    });
  }
}
