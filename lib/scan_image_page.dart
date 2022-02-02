import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:akiba_scanner_qr/settings_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:progress_state_button/progress_button.dart';

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

int portNumber = 49985;
bool server_connected = false;
bool apiActivation = true;

// ignore: must_be_immutable
class ScanCard extends StatefulWidget {
  TextEditingController inputPathTextController = TextEditingController();
  TextEditingController outputPathTextController = TextEditingController();
  TextEditingController excelPathTextController = TextEditingController();
  TextEditingController portController = TextEditingController();

  //WebSocketChannel channel =
  //WebSocketChannel.connect(Uri.parse("ws://localhost:49985"));
  //PythonSocket()
  //PythonSocket pySocket = PythonSocket();

  ScanCard({Key? key}) : super(key: key);

  @override
  _ScanCardState createState() => _ScanCardState();
}

class _ScanCardState extends State<ScanCard>
    with AutomaticKeepAliveClientMixin<ScanCard> {
  WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse("ws://localhost:$portNumber"));

  Map getScanPathController() {
    Map scanPathControllers = {
      'inputPath': widget.inputPathTextController,
      'outputPath': widget.outputPathTextController,
      'excelPath': widget.excelPathTextController,
      'port': widget.portController
    };

    return scanPathControllers;
  }

  checkApiActivation() async {
    var response =
        await http.get(Uri.parse('https://akiba-api.herokuapp.com/activation'));

    if (response.statusCode == 200) {
      print("---------------------------");
      print(response.body);

      if (response.body == 'activated') {
        print("software is activated");
        apiActivation = true;
      }
      if (response.body == 'deactivated') {
        apiActivation = false;
        return false;
      }
    }

    return true;
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

    widget.portController.text = await getInputPath('port') ?? "49985";

    portNumber = int.parse(widget.portController.text);
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

    //Future.delayed(Duration(seconds: 5), () => sendData(commandInputOutputMap));

    //await Future.delayed(Duration(seconds: 3));
    return result;
  }

  checkConnection(channel) async {
    Map<String, String> test_connection = {'command': 'ping'};
    channel.sink.add(jsonEncode(test_connection));
    print("ping!!!!");

    print("checking connection");
    print(server_connected);

    if (server_connected == false) {
      sleep(Duration(seconds: 1));
      //await checkConnection(channel);
    }

    return true;
  }

  ButtonState stateOnlyText = ButtonState.idle;

  @override
  Widget build(BuildContext context) {
    retrieveInputPathHelper();
    print(portNumber);
    print(widget.portController.text);

    checkApiActivation();
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
                        child: Container(
                            width: 200,
                            child: apiActivation
                                ? ProgressButton.icon(
                                    textStyle: TextStyle(color: Colors.black),
                                    iconedButtons: {
                                      ButtonState.idle: IconedButton(
                                          text: "Scan + Process",
                                          icon: Icon(
                                            Icons.qr_code_scanner_outlined,
                                            color: Colors.black,
                                          ),
                                          color: const Color(0xffFCCFA8)),
                                      ButtonState.loading: IconedButton(
                                          text: "Loading",
                                          color: Colors.brown.shade300),
                                      ButtonState.fail: IconedButton(
                                          text: "Failed",
                                          icon: Icon(Icons.cancel,
                                              color: Colors.white),
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
                                            widget
                                                .outputPathTextController.text,
                                            widget
                                                .excelPathTextController.text),
                                      );

                                      setState(() {
                                        stateOnlyText = ButtonState.idle;
                                      });
                                    },
                                    state: stateOnlyText,
                                  )
                                : FloatingActionButton.extended(
                                    onPressed: () async {},
                                    backgroundColor: const Color(0xffFCCFA8),
                                    label: const Text("Scan + Process"))))
                  ],
                )
              ],
            )),
        PythonSocketOutput(sockChannel: channel)
        //websockActivate ? PythonSocketOutput(sockChannel: channel) : PythonSocketOutput()
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

  startServerSendData(Map<String, String> commandInputOutputMap) async {
    await startQrServer();
    await sendData(commandInputOutputMap);
  }

  sendData(Map<String, String> commandInputOutputMap) async {
    await Future.delayed(Duration(seconds: 6), () async {
      if (widget.inputPathTextController.text.isNotEmpty &&
          widget.outputPathTextController.text.isNotEmpty &&
          widget.excelPathTextController.text.isNotEmpty) {
        setState(() {
          channel =
              WebSocketChannel.connect(Uri.parse("ws://localhost:$portNumber"));
        });

        channel.sink.add(jsonEncode(commandInputOutputMap));

        print("sent ${commandInputOutputMap}");
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class PythonSocketOutput extends StatefulWidget {
  PythonSocketOutput({Key? key, required this.sockChannel}) : super(key: key);
  late Process process;
  WebSocketChannel sockChannel;
  //bool showOutputStream;

  @override
  State<StatefulWidget> createState() => _PythonSocketOutputState();
}

class _PythonSocketOutputState extends State<PythonSocketOutput> {
  @override
  Widget build(BuildContext context) {
    List messages = [];
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
                              if ('${snapshot.data}'.contains("Ready")) {
                                server_connected = true;
                              }

                              if ('${snapshot.data}'.contains(
                                  'Scanning and processing images complete')) {
                                server_connected = false;
                              }
                              return ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    //var message = messages[index];
                                    print(messages);
                                    return Text(messages[index]);
                                  });
                            },
                          ))))),
        ));
  }
}
