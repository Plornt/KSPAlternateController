part of KSPAlternateController;


/* Scroll to bottom of page to add event constants */


class EvListener {
  Function callback;
  CustomEvent _cancel;
  String _subID;
  EvListener (Function this.callback, CustomEvent this._cancel, String subID);
  
  cancel () {
    _cancel.remove(this, _subID); 
  }
}

// Darts internal event handler is fairly rubbish (by rubbish I mean it doesnt do what I want it to :( ). So I created a worse one. Gotta 1 up them on bad code :)
abstract class CustomEvent {
  Map<String, List<EvListener>> _eventFunctions = new Map<String, List<EvListener>>();
  String subID = "";
  int eventNum;
  
  int subscriptions(String subID) {
    return _eventFunctions.length;
  }
  CustomEvent () { 
      
  }
  
  void detachAllEvents (GlobalProgramHandler context) {
    if (_eventFunctions.length > 0){
      _eventFunctions.forEach((String subID, List<EvListener> idontcare) {
        context.send(new ChangeSubscriptionToEventPacket(eventNum, false, subID));        
      });
    }
     _eventFunctions = new Map<String, List<EvListener>>();
  }
  
  void dispatchEvent (dynamic event, String subID) {
    if (_eventFunctions.containsKey(subID)) {
      _eventFunctions[subID].forEach((e) { 
        e.callback(event);        
      });
    }
  }
  
  bool isWantingUpdates () {
    return (_eventFunctions.length > 0);
  }
  
  EvListener subscribe (Function callback, [String subID = ""]) {
    if (!_eventFunctions.containsKey(subID)) _eventFunctions[subID] = new List<EvListener>();
   _eventFunctions[subID].add(new EvListener(callback, this, subID));
  }
  
  void remove (EvListener me, String subID) {
    if (_eventFunctions.containsKey(subID)) {
       _eventFunctions.remove(me);    
    }
  }
  
  void sendSubscriptionToServer (GlobalProgramHandler context, String subID, [bool fromCache = false]) {
    if (eventNum != null) {
      print(stringify(new ChangeSubscriptionToEventPacket(eventNum, true, subID, fromCache)));
      context.send(new ChangeSubscriptionToEventPacket(eventNum, true, subID, fromCache));
    }
  }
  void sendUnsubscriptionToServer (GlobalProgramHandler context, String subID) {
    if (eventNum != null) {
      context.send(new ChangeSubscriptionToEventPacket(eventNum, false, subID));
    }
  } 
}

class ThrottleChangeUpdateEvent extends CustomEvent {
  int eventNum = KSPEvents.ACTIVE_VESSEL_THROTTLE_CHANGE;
  ThrottleChangeUpdateEvent();
}

class ActiveVesselAltVelEvent extends CustomEvent {
  int eventNum = KSPEvents.ACTIVE_VESSEL_VELALT_CHANGE;
  ActiveVesselAltVelEvent();
}

class VesselVelAltChangeEvent extends CustomEvent {
  int eventNum = KSPEvents.VESSEL_VELALT_CHANGE;
  VesselVelAltChangeEvent ();
}

class KSPSceneChangeEvent extends CustomEvent {
  int eventNum = KSPEvents.KSP_SCENE_CHANGE;
  KSPSceneChangeEvent();
}

class EditorFlagChangeEvent extends CustomEvent {
  int eventNum = KSPEvents.EDITOR_FLAG_CHANGE;
  EditorFlagChangeEvent();
}
class EditorPartCountChangeEvent extends CustomEvent {
  int eventNum = KSPEvents.EDITOR_PART_COUNT_CHANGE;
  EditorPartCountChangeEvent();
}

// You're probably wondering why this is at the bottom? Well,
// You are more than likely trying to add a new event. 
// Since the file orders the packets going downwards you are going
// to put your event at the bottom. But wait, you forgot what const you are using
// Much easier to look down here :D

class KSPEvents {
  static const int ACTIVE_VESSEL_THROTTLE_CHANGE = 0;
  static const int ACTIVE_VESSEL_VELALT_CHANGE = 1;
  static const int VESSEL_VELALT_CHANGE = 2;
  static const int KSP_SCENE_CHANGE = 3;
  static const int EDITOR_FLAG_CHANGE = 4; 
  static const int EDITOR_PART_COUNT_CHANGE = 5;
}

void RegisterEvents (GlobalProgramHandler gph) {
  gph.internalRegisterEvent(new ThrottleChangeUpdateEvent());
  gph.internalRegisterEvent(new ActiveVesselAltVelEvent());
  gph.internalRegisterEvent(new VesselVelAltChangeEvent());
  gph.internalRegisterEvent(new KSPSceneChangeEvent());
  gph.internalRegisterEvent(new EditorFlagChangeEvent());
  gph.internalRegisterEvent(new EditorPartCountChangeEvent());
}
