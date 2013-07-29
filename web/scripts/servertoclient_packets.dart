part of KSPAlternateController;

//Basically a shitty Enum
// Will implement real enums when Dart adds it. (Version 1.0 of Dart)
class ServerPacketIDs {
  static const int UNKNOWN_PACKET = 1;
  static const int CONNECTION_ACCEPTED = 2;
  static const int INCORRECT_PASSWORD = 3;
  // ID 4 & 5 IS DELETED. REUSE WHERE POSSIBLE
  static const int REQUEST_ALL_VESSEL_DATA = 6;
  static const int DATA_NOT_AVAILABLE = 7;
  static const int EVENT_FIRE = 8;
  static const int RESPONSE_TO_HTTP_REQUEST = 9;
}


class PacketHandler {
  static Packet getPacketFromType (int n, dynamic d) {
    Packet p;
    switch (n) { 
      case ServerPacketIDs.UNKNOWN_PACKET:
        p = new UnknownPacket();
        break;
      case ServerPacketIDs.CONNECTION_ACCEPTED:
        p = new ConnectionAccepted(d["ID"]);
        break;
      case ServerPacketIDs.INCORRECT_PASSWORD:
        p = new IncorrectPassword(d["ID"]);
        break;
      case ServerPacketIDs.REQUEST_ALL_VESSEL_DATA:
        p = new RequestAllVesselDataServer(d["ID"], d["Vessels"]);
        break;
      case ServerPacketIDs.DATA_NOT_AVAILABLE:
        p = new DataNotAvailable(d["ID"]);
        break;
      case ServerPacketIDs.EVENT_FIRE: 
        switch (d["eID"]) {
          case KSPEvents.ACTIVE_VESSEL_THROTTLE_CHANGE:
            p = new ActiveVesselThrottleChange(d["s"]);
            break;
          case KSPEvents.ACTIVE_VESSEL_VELALT_CHANGE:
            p = new ActiveVesselAltVelChange(d["displayMode"], d["orbitVel"], d["surfaceVel"], d["targetVel"], d["altitude"]);
            break;
          case KSPEvents.VESSEL_VELALT_CHANGE:
            p = new VesselAltVelChange (d["alt"], d["orbitVelocity"], d["surfaceVelocity"], d["subID"]);
            break;
          case KSPEvents.KSP_SCENE_CHANGE:
            p = new KSPSceneChange (d["sceneName"]);
            break;
          case KSPEvents.EDITOR_FLAG_CHANGE:
            p = new EditorFlagChange (d["flagURL"], d["base64Image"]);
            break;
          case KSPEvents.EDITOR_PART_COUNT_CHANGE:
            p = new EditorPartCountChange(d["partCount"]);
            break;
        }
        break;
      case ServerPacketIDs.RESPONSE_TO_HTTP_REQUEST:
          p = new ResponseToHttpRequest(d["ID"], d["base64"], d["mimetype"], d["body"]);
        break;
    }
    if (p != null) {
      return p;
    }
    else {
      //throw new UnimplementedError();
    }    
  }
}
abstract class Packet {
  int packetID = 0;
 Packet () {
 }
 void messageHandlerHandlePacket (GlobalProgramHandler gph) {
    handlePacket(gph);
 }
 void handlePacket (GlobalProgramHandler gph) {
   
 }
}
abstract class ResponsePacket extends Packet {
  String responseID = "";
  ResponsePacket(String responseID) {
    this.responseID = responseID;
  }  
  void messageHandlerHandlePacket (GlobalProgramHandler gph) {
    if (gph.awaitingResponses.containsKey(responseID)) {
     gph.awaitingResponses[responseID].complete(this);
    }
    super.messageHandlerHandlePacket(gph);
  }
}
abstract class EventPacket extends Packet {
  int eventNum = 0;
  void handlePacket (GlobalProgramHandler gph) {
    gph.dispatchEvent(eventNum, this);
  }
}
abstract class SubEventPacket extends Packet {
  int eventNum = 0;
  String subID;
  void handlePacket (GlobalProgramHandler gph) {
    gph.dispatchEvent(eventNum, this, this.subID);
  }
}
class UnknownPacket extends Packet {
  int packetID = ServerPacketIDs.UNKNOWN_PACKET;
  UnknownPacket () { 
    
  }
}
class ConnectionAccepted extends ResponsePacket {
  int packetID = ServerPacketIDs.CONNECTION_ACCEPTED;
  UnknownPacket (String responseID):super(responseID) { 
    
  }
}
class IncorrectPassword extends ResponsePacket {
  int packetID = ServerPacketIDs.INCORRECT_PASSWORD;
  UnknownPacket (String responseID):super(responseID) { 
    
  }
}

class RequestAllVesselDataServer extends ResponsePacket {
  int packetID = ServerPacketIDs.REQUEST_ALL_VESSEL_DATA;
  List<dynamic> vesselObjects;
  RequestAllVesselDataPacket (String responseID, List<dynamic> vesselObjects):super(responseID) { 
    this.vesselObjects = vesselObjects;
  }
}
class DataNotAvailable extends ResponsePacket {
  int packetID = ServerPacketIDs.DATA_NOT_AVAILABLE;
  DataNotAvailable (String responseID):super(responseID) { 
    
  }
}

class ActiveVesselThrottleChange extends EventPacket {
  int packetID = ServerPacketIDs.EVENT_FIRE;
  int eventNum = KSPEvents.ACTIVE_VESSEL_THROTTLE_CHANGE;
  num throttleValue;
  ActiveVesselThrottleChange (num s) { 
    throttleValue = s;
  }
}

class ActiveVesselAltVelChange extends EventPacket {
  int packetID = ServerPacketIDs.EVENT_FIRE;
  int eventNum = KSPEvents.ACTIVE_VESSEL_VELALT_CHANGE;

  String displayMode;
  num orbitVelocity;
  num surfaceVelocity;
  num targetVelocity;
  double altitude;
  ActiveVesselAltVelChange (String this.displayMode, num this.orbitVelocity, num this.surfaceVelocity,
                              num this.targetVelocity, double this.altitude) { 
    
  }
}
class VesselAltVelChange extends SubEventPacket {
  int packetID = ServerPacketIDs.EVENT_FIRE;
  int eventNum = KSPEvents.VESSEL_VELALT_CHANGE;
  num orbitVelocity;
  num surfaceVelocity;
  double altitude;
  String subID;
  VesselAltVelChange (num this.altitude, num this.orbitVelocity, num this.surfaceVelocity, String this.subID) { 
    
  }
}



class KSPSceneChange extends EventPacket {
  int packetID = ServerPacketIDs.EVENT_FIRE;
  int eventNum = KSPEvents.KSP_SCENE_CHANGE;
  String sceneName;
  KSPSceneChange (String this.sceneName) { 
    
  }
}

class EditorFlagChange extends EventPacket {
  int packetID = ServerPacketIDs.EVENT_FIRE;
  int eventNum = KSPEvents.EDITOR_FLAG_CHANGE;
  String flagURL; 
  String base64Flag;
  EditorFlagChange (String this.flagURL, String this.base64Flag) {
  }
}

class EditorPartCountChange extends EventPacket {
  int packetID = ServerPacketIDs.EVENT_FIRE;
  int eventNum = KSPEvents.EDITOR_PART_COUNT_CHANGE;
  num partCount;
  EditorPartCountChange(num this.partCount) {
  }
}


class ResponseToHttpRequest extends ResponsePacket {
 int packetID = ServerPacketIDs.RESPONSE_TO_HTTP_REQUEST;
 String body;
 bool base64;
 String mimeType; 
 ResponseToHttpRequest (String responseID, bool this.base64, String this.mimeType, String this.body):super(responseID) { 
  
 }
}
