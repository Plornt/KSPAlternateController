part of KSPAlternateController;

class Editor extends Scene {
   String name = "EDITOR";
   bool buttonDisableOnChange = true;
   bool needsLogin = true;
   Element scene = query("#EDITOR");
   Element button = query("#nav-EDITOR");
   ImageElement flag = query("#Editor_Flag_Image");
   SpanElement partCount = query("#Editor_PartCount");

  void init (GlobalProgramHandler gph) {
    super.init(gph);
  }
  void afterLogin (GlobalProgramHandler gph) {
    flag.src = "";
    partCount.innerHtml = "0";
    gph.attachEvent(KSPEvents.EDITOR_FLAG_CHANGE, (EditorFlagChange ev) {
      flag.src = "data:image/png;base64,${ev.base64Flag}";
    }, fromCache: true);
    
    gph.attachEvent(KSPEvents.EDITOR_PART_COUNT_CHANGE, (EditorPartCountChange ev) {
      partCount.innerHtml = ev.partCount.toString();
    }, fromCache: true);
    
  }
}