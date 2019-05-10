import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wifi/wifi.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';
    IOWebSocketChannel channel ;
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
        channel: channel,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  WebSocketChannel channel;

  MyHomePage({Key key, @required this.title, @required this.channel})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();

  bool connected = false;
  
  Future<String> getIp() async {
      String ip = await Wifi.ip;
      return ip;
    }

 @override
  initState() {
    super.initState();
    getIp().then((onValue){
      print('IP Address : '+onValue);
      widget.channel = IOWebSocketChannel.connect('ws://'+onValue+ ':81');
      setState(() {
        connected = true;
      });
    });
  }
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Send a message'),
              ),
            ),
            Center(
              child: Text(this.connected?'Connected':''),
            ),
            StreamBuilder(
              stream: widget.channel != null ? widget.channel.stream:null,
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(snapshot.hasData ? '${snapshot.data}' : ''),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage ,
        tooltip: 'Send message',
        child: Icon(Icons.send),
        
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      widget.channel.sink.add(_controller.text);
      _controller.clear() ;
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}
