static class Colours
{
  // https://processing.org/reference/color_datatype.html
  static color create(int value)
  {
    return create(value, value, value, 0xFF);
  }

  static color create(int r, int g, int b)
  {
    return create(r, g, b, 0xFF);
  }

  static color create(int r, int g, int b, int a)
  {
    int ret = a;
    ret = (ret << 8) | r;
    ret = (ret << 8) | g;
    ret = (ret << 8) | b;
    return ret;
  }

  static void fill(int r, int g, int b)
  {
    fill(create(r, g, b));
  }

  static void fill(int colour)
  {
    Applet.get().fill(colour);
  }

  static void stroke(int colour)
  {
    Applet.get().stroke(colour);
  }

  static void strokeWeight(float weight)
  {
    Applet.get().strokeWeight(weight);
  }

  static void noStroke()
  {
    Applet.get().noStroke();
  }
}
