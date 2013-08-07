part of KSPAlternateController;

class Login extends Scene {
   bool _isLoggedIn = false;
   String name = "LOGIN";
   bool buttonDisableOnChange = false;
   bool needsLogin = false;
   Element scene = query("#LOGIN");
   Element button = query("#nav-LOGIN");
   bool get loggedIn {
    return _isLoggedIn;
   }
   ButtonElement loginButton = query("#Login_KSPLogin");
   TextInputElement loginTextBox = query("#Login_KSPPassword");
  
  void init (GlobalProgramHandler gph) {
    super.init(gph);
    loginButton.onClick.listen((t) { 
      loginButton.disabled = true;
      gph.connect(() {
        gph.sendAwaitResponse(new SendPasswordPacket("tempPass")).then((ResponsePacket response) { 
          if (response.packetID == ServerPacketIDs.CONNECTION_ACCEPTED) {
            gph.attachEvent(KSPEvents.KSP_SCENE_CHANGE, (KSPSceneChange event) { 
              print("Scene Change");
              switch (event.sceneName) {
                case "LOADING": 
                  gph.sceneHandler.ChangeScene("LOADING", "KSP");
                  break;
                case "MAINMENU":
                  gph.sceneHandler.ChangeScene("MAINMENU", "KSP");
                  break;
                case "FLIGHT":
                  gph.sceneHandler.ChangeScene("FLIGHT", "KSP");
                  break;
                case "EDITOR":
                  gph.sceneHandler.ChangeScene("EDITOR", "KSP");
                  break;
              }
            }, fromCache: true);
            _isLoggedIn = true;
            Settings settingsScene = gph.sceneHandler.getScene("SETTINGS");
            if (settingsScene.getSetting("settings_rememberPassword") == "true") {
              settingsScene.setSetting("settings_password",loginTextBox.value);
            }
            gph.sceneHandler.OnceLoggedIn();
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
   
  }
  



   void disconnect (ButtonElement loginButton, GlobalProgramHandler gph) {
    gph.close();
    gph.sceneHandler.ChangeScene("LOGIN");
    loginButton.disabled = false;
  }

}