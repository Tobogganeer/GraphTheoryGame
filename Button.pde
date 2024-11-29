import java.util.ArrayList;

static class Button
{
  static ArrayList<Button> all = new ArrayList<Button>();
  
  int normal = color(200);
  int hover = color(180, 180, 200);
  int clicked = color(215, 215, 200);
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
    stroke(0);
    strokeWeight(2);
    fill(mouseDown ? clicked : isHovered() ? hover : normal);
    rect.draw();

    // Display our text
    fill(0);
    textAlign(CENTER, CENTER);
    text(label, rect.centerX(), rect.centerY());
    Draw.end();
  }

  boolean isHovered()
  {
    // We are turned off
    if (!enabled)
      return false;
    // We have to mouse over us
    return rect.contains(mouseX, mouseY);
  }

  void setPosition(PVector pos)
  {
    rect.setPosition(pos);
  }
}
