
/**
 * WebSockets Radio - Consumer
 * author: Tony Taylor
 * date: 8.3.2012
 */

#import('dart:html');

final RegExp regex = new RegExp(r'(<source).+(src.+).+(type.+>)<');

void main() {
  WebSocket ws = new WebSocket('ws://127.0.0.1:15200/wsr-radio');
  ws.on.message.add((MessageEvent me) {
    
    Iterable<Match> matches = regex.allMatches(me.data);
    for (Match match in matches) {
      //String output = match.group(2);
      print('global match: ${match[0]}');
      print('source tag: ${match[1]}');
      print('src attribute: ${match[2]}');
      print('type attribute: ${match[3]}');
      //print(output);
      //print('output contains ${match.groupCount()} groups.');
    }
    if (!regex.hasMatch(me.data)) {
      print('regular expression has no match.');
    }

    //print(new StringBuffer(['incoming: ', me.data.toString()]));
    print(new StringBuffer(['local: ', document.query('#output').innerHTML]));
    print(me.data.toString() == document.query('#output').innerHTML);
    //if (me.data.toString().compareTo(document.query('#output').innerHTML) == false){
      document.query('#output').innerHTML = '${me.data}';
    //  print('updated client DOM.');
    //} else {
    //  print('server sent message - no change in data');
    //}
  });
  
  Element element = document.query('#serveClick');
  element.on.click.add((event) => ws.send('hey'));
}
