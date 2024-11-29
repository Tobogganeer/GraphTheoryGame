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
  boolean dragging;

  float handleFac;
  float minValue;
  float maxValue;
  boolean wholeNumbers;

  float currentValue;

  Rect handleRect;

  final float handleRadius = 16;

  Slider(Rect rect, String label, float minValue, float maxValue, boolean wholeNumbers, float defaultValue)
  {
    this.rect = rect;
    this.label = label;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.wholeNumbers = wholeNumbers;
    
    setValue(defaultValue);

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

    // "Dragging" makes sure we stay in control even if we move the mouse too fast
    dragging = mouseDown;

    if (dragging)
      handleFac = getHandleFac(app.mouseX);

    currentValue = lerp(minValue, maxValue, handleFac);
    if (wholeNumbers)
      currentValue = round(currentValue);

    // Set rect center (for mouse detection)
    handleRect.setCenter(new PVector(getHandleX(), rect.centerY()));
    app.ellipse(handleRect.centerX(), handleRect.centerY(), handleRadius, handleRadius);

    // Display label in center of bar
    Colours.fill(0);
    app.textAlign(CENTER, BASELINE);
    app.textSize(12);
    app.text(label, rect.centerX(), rect.y - 5);

    app.textAlign(LEFT, CENTER);
    String str = wholeNumbers ? Integer.toString(int(currentValue)) : String.format("%.02f", currentValue);
    app.text(str, rect.x + rect.w + 10, rect.centerY());
    Draw.end();
  }

  float getHandleX()
  {
    return rect.x + rect.w * handleFac;
  }

  float getHandleFac(float xPosition)
  {
    // Make sure we don't go out of bounds
    xPosition = Maths.clamp(xPosition, rect.x, rect.x + rect.w);
    // x = rectX + rectW * fac
    // fac = (x - rectX) / rectW
    return (xPosition - rect.x) / rect.w;
  }

  void setValue(float value)
  {
    value = Maths.clamp(value, minValue, maxValue);
    float fac = (value - minValue) / maxValue;
    handleFac = fac;
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
      s.mouseDown = (s.isHovered() || s.dragging) && lmbDown;
      s.display();
    }
  }
}
