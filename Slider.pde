import java.util.ArrayList;

static class Slider
{
  static ArrayList<Slider> all = new ArrayList<Slider>();

  color normal = Colours.create(220);
  color hover = Colours.create(180, 180, 200);
  color clicked = Colours.create(215, 215, 200);
  Rect rect;
  String label;

  boolean mouseDown;
  boolean enabled = true;

  float handleFac;
  float minValue;
  float maxValue;
  boolean wholeNumbers;

  Rect handleRect;

  final float handleRadius = 16;

  Slider(Rect rect, String label, float minValue, float maxValue, boolean wholeNumbers)
  {
    this.rect = rect;
    this.label = label;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.wholeNumbers = wholeNumbers;

    handleRect = new Rect(0, 0, handleRadius, handleRadius);

    all.add(this);
  }

  void display()
  {
    // We are turned off
    if (!enabled)
      return;

    PApplet app = Applet.get();

    Draw.start();
    // Draw background bar
    Colours.fill(normal);
    Colours.stroke(0);
    Colours.strokeWeight(1);
    rect.draw(2);

    // Draw handle
    Colours.fill(mouseDown ? clicked : isHovered() ? hover : normal);
    app.ellipseMode(CENTER);
    // Set rect center (for mouse detection)
    handleRect.setCenter(new PVector(getHandleX(), rect.centerY()));
    app.ellipse(handleRect.centerX(), handleRect.centerY(), handleRadius, handleRadius);

    // Display label in center of bar
    Colours.fill(0);
    app.textAlign(CENTER, CENTER);
    app.textSize(12);
    app.text(label, rect.centerX(), rect.centerY());
    Draw.end();
  }

  float getHandleX()
  {
    return rect.x + rect.w * handleFac;
  }

  boolean isHovered()
  {
    // We are turned off
    if (!enabled)
      return false;
    // We have to mouse over us
    return handleRect.contains(Applet.get().mouseX, Applet.get().mouseY);
  }

  void setPosition(PVector pos)
  {
    rect.setPosition(pos);
  }

  static void displayAll()
  {
    boolean lmbDown = Applet.get().mousePressed && Applet.get().mouseButton == LEFT;

    for (Slider s : all)
    {
      s.mouseDown = s.isHovered() && lmbDown;
      s.display();
    }
  }
}
