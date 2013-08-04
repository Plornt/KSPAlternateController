library KSPAlternateController;

import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:utf';
import 'dart:json';
import 'dart:mirrors';
import 'package:uuid/uuid.dart';
import 'package:pathos/path.dart' as path;

part 'packets/servertoclient_packets.dart';
part 'packets/clienttoserver_packets.dart';
part 'packets/websocket_handler.dart';
part 'events/events.dart';
part 'scenes/scene_handler.dart';
part 'scenes/editor.dart';
part 'scenes/flagbrowser.dart';
part 'scenes/inflight.dart';
part 'scenes/login.dart';
part 'scenes/mainmenu.dart';
part 'scenes/settings.dart';
part 'scenes/loading.dart';

String serverIP = "";
String serverPort = "81";
String serverPath = "";
bool loggedIn = false;

void main() {
  serverIP = window.location.hostname;
  // TODO: Setup KSP HTTP Server
  //serverPort = window.location.port;
  GlobalProgramHandler gph = new GlobalProgramHandler(serverIP, serverPort, serverPath, messageHandler);
  RegisterEvents(gph);
}


String getUUID () {
  var uuid = new Uuid();
  return uuid.v1();
}

void messageHandler (GlobalProgramHandler ws, MessageEvent message) {
  dynamic jsonObj;
  jsonObj = parse(message.data);
  if (jsonObj["t"] != null) {    
      Packet c;     
      c = PacketHandler.getPacketFromType(jsonObj["t"], jsonObj);
      if (c != null) { c.messageHandlerHandlePacket(ws); }
  }
}

