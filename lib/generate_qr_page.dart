import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GenerateQrPage extends StatefulWidget {
  const GenerateQrPage({Key? key}) : super(key: key);
  @override
  _GenerateQrPageState createState() => _GenerateQrPageState();
}


class _GenerateQrPageState extends State<GenerateQrPage>{
  @override
  Widget build(BuildContext context) {
    return ScanCard();
  }

}


class ScanCard extends StatefulWidget {
  ScanCard({Key? key}) : super(key: key);

  @override
  _ScanCardState createState() => _ScanCardState();
}



class _ScanCardState extends State<ScanCard>
{


  @override
  Widget build(BuildContext context) {
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
                                style: TextStyle(color: Color(0xffFCCFA8))),
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
            )
          ],
        ));
  }
}