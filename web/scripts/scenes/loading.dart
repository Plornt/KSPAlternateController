part of KSPAlternateController;

class Loading extends Scene {
   String name = "LOADING";
   bool buttonDisableOnChange = true;
   bool needsLogin = true;
   Element scene = query("#DEFAULT");
   Element button;

  void init (GlobalProgramHandler gph) {
    super.init(gph);
  }
  void loaded(GlobalProgramHandler gph) {
    gph.sceneHandler.ChangeScene("LOGIN");
  }
}