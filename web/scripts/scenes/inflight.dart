part of KSPAlternateController;

class Inflight extends Scene {
   String name = "INFLIGHT";
   bool buttonDisableOnChange = true;
   bool needsLogin = true;
   Element scene = query("#INFLIGHT");
   Element button = query("#nav-INFLIGHT");

  void init (GlobalProgramHandler gph) {
    super.init(gph);
  }
  
}