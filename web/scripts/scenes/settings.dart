part of KSPAlternateController;

class Settings extends Scene {
  String name = "SETTINGS";
  bool buttonDisableOnChange = false;
  bool needsLogin = false;
  Element scene = query("#SETTINGS");
  Element button = query("#nav-SETTINGS");
  Map<String, String> settings = new Map<String, String>();
  Map<String, String> previousSettings;
  
  String getSetting (String key) {
    return settings[key];
  }
  
  void setSetting(String key, String value) {
      settings[key] = value;
  }
  
  void init (GlobalProgramHandler gph) {
    super.init(gph);
    previousSettings = settings;
//    InputElement rememberPassword =  query("#MainMenu_RememberPassword");
//    query("#MainMenu_ApplicationSettings").onClick.listen((t) {
//      query("#MainMenu_Settings").style.display = "block";
//      query("#MainMenu_Buttons").style.display = "none";
//      previousSettings = settings;
//      print("Reseting");
//      rememberPassword.checked = (settings["settings_rememberPassword"] == "true");
//    });
//    
//    
//    query("#MainMenu_SaveSettings").onClick.listen((t) {
//      print("SAVED");
//      settings["settings_rememberPassword"] = rememberPassword.checked.toString();
//      if (rememberPassword.checked) {
//        settings["settings_password"] = Login.loginTextBox.value;
//      }
//      else {
//        settings["settings_password"] = "";
//      }
//      saveSettings();
//      query("#MainMenu_Buttons").style.display = "inline-block";
//      query("#MainMenu_Settings").style.display = "none";
//    });
//  
//    query("#MainMenu_CancelSettings").onClick.listen((t) {
//      print("CANCELED");
//      query("#MainMenu_Buttons").style.display = "inline-block";
//      query("#MainMenu_Settings").style.display = "none";
//    });
  }

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
}