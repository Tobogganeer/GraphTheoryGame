import java.util.ArrayList;

static class Slider
{
  static ArrayList<Slider> all = new ArrayList<Slider>();
  
  color normal = color(200);
  color hover = color(180, 180, 200);
  color clicked = color(215, 215, 200);
  Rect rect;
  String label;

  boolean mouseDown;
  boolean enabled = true;
  
  float handlePosition;
  float minValue;
  float maxValue;
  boolean wholeNumbers;

  Slider(Rect rect, String label, float minValue, float maxValue, boolean wholeNumbers)
  {
    this.rect = rect;
    this.label = label;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.wholeNumbers = wholeNumbers;
    
    all.add(this);
  }

  void display()
  {
    // We are turned off
    if (!enabled)
      return;

    Draw.start();
    // Draw background bar
    fill(normal);
    stroke(0);
    strokeWeight(1);
    rect.draw(2);
    
    // Draw handle
    fill(mouseDown ? clicked : isHovered() ? hover : normal);
    ellipse(handlePosition, rect.centerY(), 10, 10);

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
