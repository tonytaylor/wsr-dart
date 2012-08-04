
/**
 * 
 * WebSockets Radio Server
 * author: Tony Taylor
 * date: 8.3.2012
 * 
 * This stuff needs decoupling.  For instance, removeConnections should not explicitly
 * refer to the global connections list.
 */

#import('dart:io');
#import('dart:isolate');

final HOST = '127.0.0.1';
final PORT = 15200;

int count = 0;
Map<String, String> contentTypes = const {
  'html' : 'text/html; charset-UTF-8',
  'dart' : 'application/dart',
  'js'   : 'application/javascript',
};

List<WebSocketConnection> connections;

void main() {
  connections = new List();
  
  WebSocketHandler handler = new WebSocketHandler();
  handler.onOpen = (WebSocketConnection connection) {
    connections.add(connection);
    connection.onClosed = (a, b) => removeConnection(connection);
    connection.onError = (_) => removeConnection(connection);
    connection.onMessage = (MessageEvent msg) {
      print('msg received: ${msg}');
    };
    print('connecton was made to: ${connection}');
  };
  
  HttpServer server = new HttpServer();
  server.addRequestHandler(
    (HttpRequest request) => (request.path == '/wsr-radio'),
    handler.onRequest);
  server.addRequestHandler((_) => true, serveList);
  
  new Timer.repeating(5000, (Timer t) {
    var markup = '<div><p>messages sent: ${count}</p></div>';
    connections.forEach((WebSocketConnection connection) {
      connection.send(getPlaylist());
    });
    count += 1;
  });
  server.listen(HOST, PORT);
  print('server fired on ${HOST}:${PORT}');
}

void serveList(HttpRequest request, HttpResponse response) {
  String path = (request.path.endsWith('/')) ? 
      '.${request.path}index.html' : '${request.path}';
  print('serving ${path}');
  
  File file = new File(path);
  file.exists().then((bool exists) {
    if (exists) {
      file.readAsText().then((String text) {
        response.headers.set(HttpHeaders.CONTENT_TYPE, getContentType(file));
        response.outputStream.writeString(text);
      });
    } else {
      response.statusCode = HttpStatus.NOT_FOUND;
    }
    response.outputStream.close();
  });
}

String getContentType(File file) => contentTypes[file.name.split('.').last()];

void removeConnection(WebSocketConnection connection) {
  int index = connections.indexOf(connection);
  if (index > -1) {
    connections.removeRange(index, 1);
  }
}

String getPlaylist() {
  return 
    '<audio controls="controls">'.concat(
    '<source src="resources/mp3/Dead_Prez-Far_From_Over.mp3" '.concat(
    'type="audio/mpeg" />'.concat(
    '<source src="resources/mp3/Dead_Prez-Exhibit_M.mp3" '.concat(
    'type="audio/mpeg" />'.concat(
    '</audio>')))));
}