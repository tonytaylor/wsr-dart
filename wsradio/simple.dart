#import('dart:io');

void main() {
  runSimpleServer();
}

void runSimpleServer() {
  WebSocket ws = new WebSocket('ws://127.0.0.1:2020/soundbank');

  ws.onopen = (event) {
    print('Connected');
    ws.send('Welcome to the Sound Ocean');
  };

  ws.onclose = (event) {
    print('closing');
  };

  ws.onmessage = (event) {
    print('received message ${e.data}');
  };
}
