import java.util.ArrayList;

static class Button
{
  static ArrayList<Button> all = new ArrayList<Button>();

  int normal = Colours.create(200);
  int hover = Colours.create(180, 180, 200);
  int clicked = Colours.create(215, 215, 200);
  Rect rect;
  String label;

  boolean mouseDown;
  boolean enabled = true;

  Button(float x, float y, float w, float h, String label)
  {
    rect = new Rect(x, y, w, h);
    this.label = label;
    //this.applet = applet;

    all.add(this);
  }

  void display()
  {
    // We are turned off
    if (!enabled)
      return;

    Draw.start();
    // Set colour and display our rect
    Colours.stroke(0);
    Colours.strokeWeight(2);
    Colours.fill(mouseDown ? clicked : isHovered() ? hover : normal);
    rect.draw();

    // Display our text
    Colours.fill(0);
    Applet.get().textAlign(CENTER, CENTER);
    Applet.get().text(label, rect.centerX(), rect.centerY());
    Draw.end();
  }

  boolean isHovered()
  {
    // We are turned off
    if (!enabled)
      return false;
    // We have to mouse over us
    return rect.contains(Applet.get().mouseX, Applet.get().mouseY);
  }

  void setPosition(PVector pos)
  {
    rect.setPosition(pos);
  }

  static void displayAll()
  {
    boolean lmbDown = Applet.get().mousePressed && Applet.get().mouseButton == LEFT;

    for (Button b : all)
    {
      b.mouseDown = b.isHovered() && lmbDown;
      b.display();
    }
  }
}
