part of KSPAlternateController;


abstract class Scene {
  String name;
  bool buttonDisableOnChange;
  bool needsLogin;
  Element scene;
  Element button;
  Function sceneStartup;

  void init (GlobalProgramHandler gph) {
    if (button != null) {
      button.onClick.listen((ev) {
        if (!this.button.classes.contains("disabled")) {
          gph.sceneHandler.ChangeScene(this.name);
        }
      });
      if (needsLogin) {
         button.classes.add("disabled");
      }
      if (buttonDisableOnChange) {
        button.classes.add("disabled");
      }
    }
  }
  void loaded (GlobalProgramHandler gph) {
   
  }
  void afterLogin (GlobalProgramHandler gph) {
    
  }
}

class SceneHandler {
  List<Scene> scenes = new List<Scene>();
  Element previousScene;
  GlobalProgramHandler parent;
  
  
  void OnceLoggedIn () {
    scenes.forEach((E) {
      if (E.button != null && E.needsLogin == true && E.buttonDisableOnChange ==false) {
        E.button.classes.remove("disabled");
      }
      E.afterLogin(parent);
    });
  }  
  
  Scene getScene (String name) {
    return scenes.where((S) { return (S.name == name); }).first;
  }
  
  void addScene (Scene scene) {
    scenes.add(scene);  
  }
  
  void init (GlobalProgramHandler gph) {
    parent = gph;
    MirrorSystem mirr = currentMirrorSystem();
    IsolateMirror iso = mirr.isolate;
    iso.rootLibrary.classes.forEach((k, v) {
      if (v.superclass != null) {
        if (v.superclass.simpleName == new Symbol("Scene")) {
          InstanceMirror instance = v.newInstance(new Symbol(""),[]);
          instance.reflectee.init(gph);
          addScene(instance.reflectee);
          
        }
      }
    });
    previousScene = getScene("LOADING").scene;
    scenes.forEach((E) {
      E.loaded(gph);
    });
  }
 
  void ChangeScene (String scene, [String origin = null]) {
    Scene E = scenes.where((S) { return (S.name == scene); }).first;
    if (E != null) {
      List<Element> el = queryAll(".active");
      el.forEach((Element e) { 
        e.classes.remove("active");
      });
      previousScene.style.display = "none";
      previousScene = E.scene;
      E.scene.style.display = "block";
      if (E.button != null) {
        E.button.classes.add("active");
        E.button.classes.remove("disabled");
      }
      if (origin == "KSP") {
        scenes.where((S) { return (S.buttonDisableOnChange == true && S.name != scene && S.button != null) || (loggedIn == false && S.button != null && S.needsLogin); }).forEach((E) {
            E.button.classes.add("disabled");
        });
      }
    }
  }
}