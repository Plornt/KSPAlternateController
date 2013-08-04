part of KSPAlternateController;


class MainMenu extends Scene {
   String name = "MAINMENU";
   bool buttonDisableOnChange = true;
   bool needsLogin = false;
   Element scene = query("#MAINMENU");
   Element button = query("#nav-MAINMENU");

  void init (GlobalProgramHandler gph) {
    super.init(gph);
   
    
  }
  void afterLogin (GlobalProgramHandler gph) {
    query("#MainMenu_Disconnect").onClick.listen((t) {
      Login loginScene = gph.sceneHandler.getScene("LOGIN");
      loginScene.disconnect(loginScene.loginButton, gph);
    });
  }
}