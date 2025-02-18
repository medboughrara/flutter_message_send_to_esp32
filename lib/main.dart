import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebSocketTestScreen(),
    );
  }
}

class WebSocketTestScreen extends StatefulWidget {
  @override
  _WebSocketTestScreenState createState() => _WebSocketTestScreenState();
}

class _WebSocketTestScreenState extends State<WebSocketTestScreen> {
  late IOWebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connectToWebSocket();
  }

  void connectToWebSocket() {
    channel = IOWebSocketChannel.connect('ws://192.168.1.12:81');
    channel.stream.listen((message) {
      setState(() {
        messages.add('Received: $message');
      });
    }, onError: (error) {
      print('Error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    });
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      channel.sink.add(message);
      setState(() {
        messages.add('Sent: $message');
        _controller.clear();
      });
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter message',
              ),
              onSubmitted: (value) {
                sendMessage(value);
              },
            ),
            ElevatedButton(
              onPressed: () {
                sendMessage(_controller.text);
              },
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}