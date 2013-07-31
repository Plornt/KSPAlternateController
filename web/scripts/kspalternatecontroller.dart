library KSPAlternateController;

import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:utf';
import 'dart:json';
import 'package:uuid/uuid.dart';
import 'package:pathos/path.dart' as path;
import 'package:js/js.dart' as js;

part 'servertoclient_packets.dart';
part 'clienttoserver_packets.dart';
part 'websocket_handler.dart';
part 'events.dart';

String serverIP = "";
String serverPort = "81";
String serverPath = "";

Map<String, Element> scenes = new Map<String, Element>();
void main() {
  serverIP = window.location.hostname;
  
  loadSettings();
    
  // TODO: Setup KSP HTTP Server
  //serverPort = window.location.port;
  
  /*
   * Load Generic Functions
   */
  print( query("#DEFAULT").runtimeType);
  Element loadingScene = query("#DEFAULT");
  previousScene = loadingScene;
  Element loginScene = query("#LOGIN");
  scenes.putIfAbsent("LOADING", () { return loadingScene; });  
  scenes.putIfAbsent("LOGIN", () { return loginScene; });  
  /*scenes.putIfAbsent("MAINMENU", () { return query("#MAINMENU"); });  
  scenes.putIfAbsent("FLIGHT", () { return query("#FLIGHT"); });  
  scenes.putIfAbsent("EDITOR", () { return query("#EDITOR"); }); 
  scenes.putIfAbsent("FLAGBROWSER", () { return query("#FLAGBROWSER"); }); */
  GlobalProgramHandler gph = new GlobalProgramHandler(serverIP, serverPort, serverPath, messageHandler);
  RegisterEvents(gph);

  /*
   *  Login Screen Logic
   */

  ButtonElement loginButton = query("#Login_KSPLogin");
  TextInputElement loginTextBox = query("#Login_KSPPassword");
  loginTextBox.value = settings["settings_password"];
  loginButton.onClick.listen((t) { 
    js.context.$("#Login_KSPLogin").button('loading');
   // loginButton.disabled = true;
    gph.connect(() {
      gph.sendAwaitResponse(new SendPasswordPacket("tempPass")).then((ResponsePacket response) { 
        if (response.packetID == ServerPacketIDs.CONNECTION_ACCEPTED) {
          SetupSceneHandler(gph);
          OnceLoggedIn(gph);
          if (settings["settings_rememberPassword"] == "true") {
            settings["settings_password"] = loginTextBox.value;
          }
        }
        else {
          window.alert("The password you entered was incorrect");
          loginButton.disabled = false;
        }
      });
    }, onClose: () { 
      disconnect(loginButton, gph);
    });    
  });
  

  ChangeScene("LOGIN");

}


bool likelyAnImage (String url) {
  return getValidExtension (url) != "";
}
String getValidExtension (String url) {
  List<String> extensions = ["jpg","png","gif"];
  Uri path = Uri.parse(url);
  for (int i = 0; i < extensions.length; i ++) { 
     if (path.path.endsWith(extensions[i])) {
       return extensions[i];
     }
  }
  return "";
}
String imgurAddExtension (String url) {
  Uri path = Uri.parse(url);
  if (path.host == "imgur.com" || path.host == "www.imgur.com") {
    if (getValidExtension (url) == "") {
       return "$url.png";
    }
  }
  return url;
}

/* CONTINUE LOADING SCREENS */
String afterID;
void OnceLoggedIn (GlobalProgramHandler gph) {
  ButtonElement loginButton = query("#Login_KSPLogin");
  TextInputElement loginTextBox = query("#Login_KSPPassword");
  /*
   * Main Menu Logic
   */
  query("#MainMenu_Disconnect").onClick.listen((t) {
      disconnect(loginButton, gph);
  });
  
  /* 
   * Settings Screen Logic
   */
  previousSettings = settings;
  InputElement rememberPassword =  query("#MainMenu_RememberPassword");
  query("#MainMenu_ApplicationSettings").onClick.listen((t) {
    query("#MainMenu_Settings").style.display = "block";
    query("#MainMenu_Buttons").style.display = "none";
    previousSettings = settings;
    print("Reseting");
    rememberPassword.checked = (settings["settings_rememberPassword"] == "true");
  });
  
  
  query("#MainMenu_SaveSettings").onClick.listen((t) {
      print("SAVED");
      settings["settings_rememberPassword"] = rememberPassword.checked.toString();
      if (rememberPassword.checked) {
        settings["settings_password"] = loginTextBox.value;
      }
      else {
        settings["settings_password"] = "";
      }
      saveSettings();
      query("#MainMenu_Buttons").style.display = "inline-block";
      query("#MainMenu_Settings").style.display = "none";
  });

  query("#MainMenu_CancelSettings").onClick.listen((t) {
    print("CANCELED");
    query("#MainMenu_Buttons").style.display = "inline-block";
    query("#MainMenu_Settings").style.display = "none";
  });
  

  /*
   * Editor Scene
   */
  InputElement moreButton = query("#FlagBrowser_More");
  HtmlElement tBody = query("#FlagBrowser_TableBody");
  HtmlElement table = query("#FlagBrowser_Table");
  void disableMoreButton () {
   moreButton.disabled = true;
   moreButton.value = "There are no more results to display.";
  }
  
  List<List<String>> processingList = new List<List<String>>();
  
  void addToFlagProcessor (String path, String author, String score) {
    processingList.add([path, author, score]);
  }
  void addImageToTable (ImageElement image) {
    
  }
  
  void processFlags() {
    processingList.forEach((List<String> map) {
      String path = map[0];
      print("Processing $path");
      gph.sendAwaitResponse(new GetCrossOriginHTML(path)).then((ResponseToHttpRequest response) {
        if (response.base64) {
          try {
          ImageElement im = new ImageElement();
            im.src = "data:${response.mimeType};base64,${response.body}";
            im.onLoad.listen((t) {
               if (im.width == 256) {
                 if (im.height == 160) {
                   //Valid image
                   print("valid");
                   tBody.appendHtml("<tr><td><img src=\"${im.src}\" /></td><td><h1>${map[1]}</h1></td><td>${map[2]}</td><td></td></tr>");

                   addImageToTable(im);
                 }
               }
               processingList.remove(path);
            });
            im.onError.listen((t) {
              print("Invalid Err: ${path}");
               processingList.remove(path);
            });
          }
          catch (e) {
            print("Invalid: ${path}");
            processingList.remove(path);
          }
        }
        else processingList.remove(path);
      });

    });
  }
  query("#Editor_Flag_Image").onClick.listen((t) { 
    ChangeScene("FLAGBROWSER");   
    afterID = "";//FlagBrowser_Table
    tBody.remove();
    table.appendHtml("<tbody id=\"FlagBrowser_TableBody\"></tbody>");
    tBody = query("#FlagBrowser_TableBody");
    moreButton.disabled = true;
    if (moreButton != null) moreButton.value = "View More";
    gph.sendAwaitResponse(new GetCrossOriginHTML("http://www.reddit.com/r/KSPFlags/hot.json")).then((ResponseToHttpRequest response) {
      print("Got response");
      try {
       dynamic json = parse(response.body);
       if (json["kind"] == "Listing") {
           if (json["data"] != null) {
             if (json["data"]["children"] != null) {
               bool foundListings = false;
               json["data"]["children"].forEach((dynamic val) {
                  if (val["kind"] == "t3") {
                     if (val["data"] != null) {
                       dynamic post = val["data"];
                       print("Adding: ${post["url"]}");
                        addToFlagProcessor(imgurAddExtension(post["url"]), post["author"], post["score"].toString());
                        
                     }
                  }
               });                 
             }
             else disableMoreButton();
           }
           else disableMoreButton();
       }
       else disableMoreButton();
       moreButton.disabled = false;
       processFlags();
      } 
      catch (e) {
        // Reddit has barfed or we have reached end of page.
        disableMoreButton();
      }
    });
    
    
  });

  ImageElement flag = query("#Editor_Flag_Image");
  HtmlElement partCount = query("#Editor_PartCount");
  flag.src = "";
  partCount.innerHtml = "0";
  gph.attachEvent(KSPEvents.EDITOR_FLAG_CHANGE, (EditorFlagChange ev) {
    print("Received flag update");
    flag.src = "data:image/png;base64,${ev.base64Flag}";
  }, fromCache: true);
  
  gph.attachEvent(KSPEvents.EDITOR_PART_COUNT_CHANGE, (EditorPartCountChange ev) {
    print("Part update");
    partCount.innerHtml = ev.partCount.toString();
  }, fromCache: true);
  
}

Map<String, String> settings = new Map<String, String>();
Map<String, String> previousSettings;
void loadSettings () {
  if (window.localStorage != null) {
    window.localStorage.forEach((String key, String value) {
       if (key.startsWith("settings_")) settings[key] = value;
    });    
    settings.putIfAbsent("settings_rememberPassword", () { return "true"; });
    settings.putIfAbsent("settings_password", () { return ""; });
  }
}
void saveSettings() {
  settings.forEach((String key, String value) { 
    window.localStorage[key] = value;
  });
}

void disconnect (ButtonElement loginButton, GlobalProgramHandler gph) {
  gph.close();
  ChangeScene("LOGIN");
  loginButton.disabled = false;
}

void SetupSceneHandler (GlobalProgramHandler gph) {
  gph.attachEvent(KSPEvents.KSP_SCENE_CHANGE, (KSPSceneChange event) { 
    switch (event.sceneName) {
      case "LOADING": 
        ChangeScene("LOADING");
        break;
      case "MAINMENU":
        ChangeScene("MAINMENU");
        break;
      case "FLIGHT":
        ChangeScene("FLIGHT");
        break;
      case "EDITOR":
        ChangeScene("EDITOR");
        break;
    }
  }, fromCache: true);
}

Element previousScene;
void ChangeScene (String scene) {
  // FUCK IT DEAL WITH ANIMATIONS LATER
  // TODO: DEAL WITH THIS.
  if (scenes.containsKey(scene)) {
    print("Trying to display scene: ${scene}");
    print("Attempting scene change");
    previousScene.style.display = "none";
    previousScene = scenes[scene];
    scenes[scene].style.display = "block";
    /*
    previousScene.classes.remove("fadeInLeft");
    previousScene.classes.add("fadeOutRight");
    scenes[scene].classes.add("fadeInLeft");
    */
  }
}

class Vessel {
  //Static
  static List<Vessel> activeVessels = new List<Vessel>();
  
  // Internal
  
  String ID;
  String name;
  num missionTime;
  num launchTime;
  String type;
  bool landedOrSplashed;
  
  Vessel (GlobalProgramHandler context, this.ID, this.name, this.missionTime, this.launchTime, this.type, this.landedOrSplashed) {
   
  }  
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

