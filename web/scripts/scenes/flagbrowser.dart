part of KSPAlternateController;

class FlagBrowser extends Scene {
   String name = "FLAGBROWSER";
   bool buttonDisableOnChange = false;
   bool needsLogin = true;
   Element scene = query("#FLAGBROWSER");
   Element button = query("#nav-FLAGBROWSER");
   ButtonElement moreButton = query("#FlagBrowser_More");
   DivElement FlagItems = query("#FlagBrowser_Items");
   String afterID = "";
   List<List<String>> processingList = new List<List<String>>();
  
  void init (GlobalProgramHandler gph) {
    super.init(gph);
  }
  void afterLogin (GlobalProgramHandler gph) {
    [query("#Editor_Flag_Image"), button].forEach((E) { 
      E.onClick.listen((t) { 
        gph.sceneHandler.ChangeScene("FLAGBROWSER");   
        if (moreButton != null) moreButton.value = "View More";
        if (afterID == "") {
          loadMoreFlags(gph);
        }
      });
    });
    query("#FlagBrowser_More").onClick.listen((ev) { 
      loadMoreFlags(gph);
    });

  }
  void disableMoreButton () {
   moreButton.disabled = true;
   moreButton.value = "There are no more results to display.";
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
  
  void addToFlagProcessor (String path, String author, String score, String title) {
    processingList.add([path, author, score, title]);
  }
  
  void displayImage (ImageElement image, String author, String score, String title) {
    DivElement imContainer = new DivElement();
    DivElement caption = new DivElement();
    HeadingElement CaptionTitle = new HeadingElement.h4();
    ParagraphElement text = new ParagraphElement();
    ParagraphElement scoreElement = new ParagraphElement();
    ParagraphElement buttons = new ParagraphElement();
    LinkElement button = new LinkElement();
    imContainer.classes.add("thumbnail");
    image.alt = title;
    imContainer.classes.add("thmbwidth");
    CaptionTitle.innerHtml = title;
    text.innerHtml = "Created by $author";
    scoreElement.innerHtml = "Score: $score";
    buttons.classes.add("alignBottom");
    button.classes.add("btn");
    button.classes.add("btn-primary");
    button.classes.add("btn-block");
    button.innerHtml = "Import";
    buttons.append(button);
    caption.append(CaptionTitle);
    caption.append(text);
    caption.append(scoreElement);
    caption.append(buttons);
    imContainer.append(image);
    imContainer.append(caption);
    FlagItems.append(imContainer);
  }
  
  void processFlags(GlobalProgramHandler gph) {
    processingList.forEach((List<String> currentComment) {
      String path = currentComment[0];
      gph.sendAwaitResponse(new GetCrossOriginHTML(path)).then((ResponseToHttpRequest response) {
        if (response.base64) {
          try {
            ImageElement im = new ImageElement();
            im.src = "data:${response.mimeType};base64,${response.body}";
            im.onLoad.listen((t) {
               if (im.width == 256) {
                 if (im.height == 160) {
                   displayImage(im, currentComment[1], currentComment[2], currentComment[3]);
                 }
               }
            });
          }
          catch (e) {
            print("Invalid: ${path}");
          }
        }
      });
  
    });
  }
  void loadMoreFlags (GlobalProgramHandler gph) {
    moreButton.disabled = true;
    gph.sendAwaitResponse(new GetCrossOriginHTML("http://www.reddit.com/r/KSPFlags/hot.json?t=all&after=$afterID&limit=15")).then((ResponseToHttpRequest response) {
      print("Got response");
      processingList = new List<List<String>>();
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
                    addToFlagProcessor(imgurAddExtension(post["url"]), post["author"], post["score"].toString(), post["title"]);
                    
                  }
                }
              }); 
            }
            else disableMoreButton();
            afterID = json["data"]["after"];
          }
          else disableMoreButton();
          
        }
        else disableMoreButton();
        moreButton.disabled = false;
        processFlags(gph);
      } 
      catch (e) {
        // Reddit has barfed or we have reached end of page.
        disableMoreButton();
      }
    }); 
  }
}