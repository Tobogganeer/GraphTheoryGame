static class Popup
{
  private static ArrayList<PopupInstance> popups = new ArrayList<PopupInstance>();
  private static final int spacing = 30;

  static void show(String content, float seconds)
  {
    int frames = (int)(seconds * Applet.get().frameRate);
    popups.add(new PopupInstance(content, frames));
    println("Popup: " + content);
  }

  static void update()
  {
    for (int i = popups.size(); i > 0; )
    {
      i--;
      PopupInstance instance = popups.get(i);
      instance.frames--;

      if (instance.frames <= 0)
      {
        popups.remove(i);
      } else
      {
        drawInstance(i, instance);
      }
    }
  }

  private static void drawInstance(int index, PopupInstance instance)
  {
    PApplet app = Applet.get();
    
    float w = app.textWidth(instance.label);
    float padding = 10;
    float y = app.height / 2 + spacing * index;

    Draw.start();
    app.fill(255);
    app.rectMode(PConstants.CENTER);
    app.rect(app.width / 2, y, w + padding * 2, 24);
    app.rectMode(PConstants.CORNER);

    app.fill(0);
    app.textAlign(PConstants.CENTER, PConstants.CENTER);
    app.text(instance.label, app.width / 2, y);
    Draw.end();
  }

  static class PopupInstance
  {
    String label;
    int frames;

    PopupInstance(String label, int frames)
    {
      this.label = label;
      this.frames = frames;
    }
  }
}
