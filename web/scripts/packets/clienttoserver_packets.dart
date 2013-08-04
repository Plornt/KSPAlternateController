part of KSPAlternateController;
class RequiresResponsePacket {
  String ID;
}
class SendPasswordPacket extends RequiresResponsePacket {
  int t = 1;
  String password = "";
  String ID;
  SendPasswordPacket (this.password) { 
  }
  toJson () {
    return { "t": t, "password": password, "ID": ID };
  }
}

class ThrottleChangeUpdatePacket {
  num s;
  int t = 2;
  ThrottleChangeUpdatePacket (this.s) { 
  }
  toJson () {
    return { "t": t, "s": s };
  }
}
class ActivateNextStagePacket {
  int t = 3;
  ActivateNextStagePacket () {
   
  }
  toJson () {
    return { "t": t };
  }
}

class RequestAllVesselDataPacket extends RequiresResponsePacket {
  int t = 4;
  String ID;
  RequestAllVesselDataPacket () {
  }
  toJson () {
    return { "t": t , "ID": ID };
  }
}

class ChangeSubscriptionToEventPacket {
  int t = 5;
  int eventNum;
  bool sendEvents;
  String subID;
  bool fromCache;
  ChangeSubscriptionToEventPacket (int this.eventNum, bool this.sendEvents, String this.subID, [bool this.fromCache = false]) {
    
  }
  toJson () {
    return { "t": t, "eNum": eventNum, "sendEvents": sendEvents, "subEventID": subID, "cached": fromCache };
  }
}

class GetCrossOriginHTML extends RequiresResponsePacket {
  int t = 6;
  String URL;
  String ID;
  GetCrossOriginHTML (String this.URL) {
    
  }
  toJson () {
    return { "t": t, "ID": ID, "url": URL};
  }
}






























