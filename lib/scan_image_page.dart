import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  TextEditingController _controller = TextEditingController();

  WebSocketChannel channel = WebSocketChannel.connect(Uri.parse("ws://localhost:49985"));

  ScanCard({Key? key}) : super(key: key);

  @override
  _ScanCardState createState() => _ScanCardState();
}

class _ScanCardState extends State<ScanCard> with AutomaticKeepAliveClientMixin<ScanCard>
{
  @override
  Widget build(BuildContext context) {
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
                                  controller: widget._controller,
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
                        onPressed: () {},
                        child: const Text('Browse'),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                const Text("Path to output Folder",
                                    style: TextStyle(color: Color(0xffFCCFA8)
                                    )
                                ),
                                TextFormField(
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
                        onPressed: () {},
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
                                  style: TextStyle(color: Color(0xffFCCFA8)
                                  )
                              ),
                              TextFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide:
                                      const BorderSide(color: Colors.grey),
                                    ),
                                  )),
                            ],
                          )
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FloatingActionButton.extended(onPressed:sendData, label: const Text("Scan + Process")),)
                  ],
                )
              ],
            )),
        PythonSocketOutput(widget.channel)
      ],
    );
  }

  void sendData() {
    if (widget._controller.text.isNotEmpty)
      {
        widget.channel.sink.add(widget._controller.text);
      }
  }

  @override
  bool get wantKeepAlive => true;
}


class PythonSocketOutput extends StatefulWidget{
  const PythonSocketOutput(this.sockChannel, {Key? key}) : super(key: key);

  final WebSocketChannel sockChannel;

  @override
  State<StatefulWidget> createState() => _PythonSocketOutputState();

}

class _PythonSocketOutputState extends State<PythonSocketOutput>
{
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
                decoration: BoxDecoration(
                  //shape: BoxShape.rectangle,
                  //border: Border.all(width: 5.0, color: Colors.black),
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                ),
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                   child: Align(
                      alignment: Alignment.bottomLeft,
                      child: StreamBuilder(
                        stream: widget.sockChannel.stream,
                        builder: (context, snapshot) {
                          messages.add(snapshot.hasData ? '${snapshot.data}' : '');
                          return ListView.builder(
                            itemCount: messages.length,
                              itemBuilder: (context, index){
                              var message = messages[index];
                                print(messages);
                                return Text(messages[index]);
                              });
                        },
                      )
                    )
                )
              )
          ),
        )


    );
  }

}