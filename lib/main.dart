import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebSocketChannel channel;
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connectToKrakenWebSocket();
  }

  void connectToKrakenWebSocket() {
    channel = IOWebSocketChannel.connect('wss://ws.kraken.com/v2');

    subscribeToMarketDataStreams();

    channel.stream.listen((message) {
      setState(() {
        messages.add('Received message: $message');
      });
    });
  }

  void subscribeToMarketDataStreams() {
    channel.sink.add(json.encode({
      "method": "subscribe",
      "params": {
        "channel": "book",
        "depth": 10,
        "snapshot": true,
        "symbol": ["BTC/USD"]
      },
      "req_id": 1234567890
    }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Kraken WebSocket'),
        ),
        body: Center(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(messages[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
