
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
  'txt'  : 'text/plain',
  'html' : 'text/html; charset-UTF-8',
  'dart' : 'application/dart',
  'js'   : 'application/javascript',
  'mp3'  : 'audio/mpeg',
  'ogg'  : 'audio/ogg',
  'wav'  : 'audio/wav'
};

List<WebSocketConnection> connections;

void main() {
  connections = new List();
  
  WebSocketHandler handler = new WebSocketHandler();
  handler.onOpen = (WebSocketConnection connection) {
    connections.add(connection);
    print('activating connection');
    connection.onClosed = (a, b) => removeConnection(connection);
    //connection.onError = (_) => removeConnection(connection);
    connection.onMessage = (String msg) {
      print('msg received: ${msg}');
    };
    print('connecton was made to: ${connection.hashCode}');
  };
  
  HttpServer server = new HttpServer();
  server.addRequestHandler(
    (HttpRequest request) => (request.path == '/wsr-radio'),
    handler.onRequest);
  server.addRequestHandler((_) => true, serveFile);

  new Timer(5000, (Timer t) {

  connections.forEach((WebSocketConnection connection) {
    connection.send(getPlaylist());
  });

  count += 1;
  });
  
  /*new Timer.repeating(5000, (Timer t) {
    var markup = '<div><p>messages sent: ${count}</p></div>';
    connections.forEach((WebSocketConnection connection) {
      connection.send(getPlaylist());
    });
    count += 1;
  });*/
  server.listen(HOST, PORT);
  print('server fired on ${HOST}:${PORT}');
}

void serveFile(HttpRequest request, HttpResponse response) {
  String path = (request.path.endsWith('/')) ? 
      '.${request.path}index.html' : '${request.path}';
  print('serving ${path}');
  
  String fullPath = '/home/tony/Documents/dev/dart/projects/web/sockets/'
                    'wsradio${path}';

  File file = new File.fromPath(new Path(fullPath));

  if (file.existsSync()) {
    response.headers.set(HttpHeaders.CONTENT_TYPE, getContentType(file));
    //print(request.headers[HttpHeaders.USER_AGENT]);

    if (isAMediaRequest(getContentType(file)) == false) { 
      file.readAsString().then((String text) {
        response.outputStream.writeString(text);
        response.outputStream.close();
      });
    } else {
      file.readAsBytes().then((List<int> bytestream) {
        response.outputStream.write(bytestream);
        response.outputStream.close();
      });
    }
  } else {
    response.statusCode = HttpStatus.NOT_FOUND;
  }
  

  /*File file = new File.fromPath(new Path(fullPath));
  file.exists().then((bool exists) {
    if (exists) {
      file.readAsString().then((String text) {
        print(text);
        response.outputStream.writeString('foo');
      });
    } else {
      response.statusCode = HttpStatus.NOT_FOUND;
    }
    response.outputStream.close();
  });*/
}

String getContentType(File file) {
  //file.name.split('.').forEach( (substr) => print(substr) );
  return contentTypes[file.name.split('.')[1]];
}

bool isAMediaRequest(String contentType) {
  return contentType.startsWith('audio') ||
         contentType.startsWith('video');
}

void removeConnection(WebSocketConnection connection) {
  int index = connections.indexOf(connection);
  if (index > -1) {
    connections.removeRange(index, 1);
  }
}

String getPlaylist() {
  return 
    '<audio controls="controls">'.concat(
    '<source src="jam01.ogg" '.concat(
    'type="audio/ogg" />'.concat(
    '<source src="10_bricks.mp3" '.concat(
    'type="audio/mpeg" />'.concat(
    '</audio>')))));
}
