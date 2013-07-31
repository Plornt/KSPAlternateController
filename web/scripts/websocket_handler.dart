part of KSPAlternateController;

class GlobalProgramHandler {
  WebSocket ws;
  String sIP;
  String sPort;
  String sPath;
  Function messageHandler;
  Map<String, CustomEvent> eventList = new Map<String, CustomEvent>();
  Map<String, Completer> awaitingResponses = new Map<String, Completer>();
  
  /// Creates a new handler ready for connection via [connect()]
  GlobalProgramHandler (String this.sIP, String this.sPort, String this.sPath, Function this.messageHandler) {
        
  }
  
  void dispatchEvent (int eventNum, dynamic event, [String subID = ""]) {
    // Its a string because of the way I used to have it.
    // TODO: CHANGE THIS TO int
    String eventName = eventNum.toString();
    if (eventList.containsKey(eventName)) {
      CustomEvent ev = eventList[eventName];
      if(ev.subscriptions(subID) == 0) { 
        ev.sendUnsubscriptionToServer(this, subID);
      }
      else {
        ev.dispatchEvent(event, subID);
      }
    }
  }
  
  void internalRegisterEvent (CustomEvent ev) {
    String eventName = ev.eventNum.toString();
    eventList[eventName] = ev;
  }
  
  void _detachAllEvents () {
     eventList.forEach((k, v) {
       v.detachAllEvents(this);
     });
  }
  
  bool detachEvent (EvListener evL) {
     evL.cancel();
  }
  
  bool attachEvent (int eventNum, Function callback, {String subID: "", bool fromCache: false}) {
    String eventName = eventNum.toString();
    if (eventList.containsKey(eventName)) {
        CustomEvent ev = eventList[eventName];
        ev.subscribe(callback, subID);
        if(ev.subscriptions(subID) == 1) { 
         ev.sendSubscriptionToServer(this, subID, fromCache);
        }
       return true;
    }
    else return false;
  }
  
  void connect(Function onOpen, { onClose: Function }) {
    print("Attemping Connection");
    // Not connected so we can no longer send messages to the server. 
    ws = new WebSocket ("ws://$sIP:$sPort/$sPath");
    ws.onMessage.listen((MessageEvent message) { messageHandler(this, message); });
    ws.onClose.listen((CloseEvent e) { print("Closed because closed. ${e.reason}"); /* window.location.reload();*/ });
    ws.onError.listen((Event e) { print("Closed due to error"); /* window.location.reload();*/ });
    ws.onOpen.listen((e) { 
      onOpen();
    });
  }
  
  /// Sends a message on the WebSocket if it can. Returns true if succeeded.
  bool send (dynamic message, [bool asJson = true]) {
    if (ws.readyState == 1) { 
      if (asJson)  ws.send(stringify(message));
      else ws.send(message);
      return true;
    }
    else return false;
  }
  
  Future<dynamic> sendAwaitResponse (RequiresResponsePacket message) {
    String ID = getUUID();
    Completer c = new Completer ();
    message.ID = ID;
    awaitingResponses[ID] = c;
    send(message);
    print(stringify(message));
    return c.future;
  }
  void close () {
    _detachAllEvents();
    ws.close(); 
  }
}