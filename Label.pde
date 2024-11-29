import java.util.ArrayList;

static class Label
{
  static ArrayList<Label> all = new ArrayList<Label>();
  int normal = Colours.create(230);

  Rect rect;
  String label;
  float fontSize;

  boolean enabled = true;

  Label(float x, float y, float w, float h, String label, float fontSize)
  {
    rect = new Rect(x, y, w, h);
    this.label = label;
    this.fontSize = fontSize;

    all.add(this);
  }

  void display()
  {
    // We are turned off
    if (!enabled)
      return;

    Draw.start();
    // Set colour and display our rect
    //Colours.stroke(180);
    //Colours.strokeWeight(1);
    Colours.noStroke();
    Colours.fill(normal);
    rect.draw(5f);

    // Display our text
    Colours.fill(0);
    Applet.get().textAlign(CENTER, CENTER);
    Applet.get().textSize(fontSize);
    Applet.get().text(label, rect.centerX(), rect.centerY());
    Draw.end();
  }

  void setPosition(PVector pos)
  {
    rect.setPosition(pos);
  }

  static void displayAll()
  {
    for (Label l : all)
      l.display();
  }
}
