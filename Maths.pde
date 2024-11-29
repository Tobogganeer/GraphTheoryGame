static class Rect
{
  float x, y, w, h;

  Rect()
  {
    x = 0;
    y = 0;
    w = 0;
    h = 0;
  }

  Rect(float x, float y, float w, float h)
  {
    this.x = x;
    this.y = y;
    this.w = abs(w);
    this.h = abs(h);
  }

  Rect(PVector position, PVector size)
  {
    this(position.x, position.y, size.x, size.y);
  }

  static Rect center(float centerX, float centerY, float w, float h)
  {
    return new Rect(centerX - w / 2, centerY - h / 2, w, h);
  }

  static Rect shrink(Rect rect, float x, float y)
  {
    return new Rect(rect.x + x / 2, rect.y + y / 2, rect.w - x, rect.h - y);
  }

  static Rect shrink(Rect rect, float amount)
  {
    return shrink(rect, amount, amount);
  }

  static Rect grow(Rect rect, float x, float y)
  {
    return shrink(rect, -x, -y);
  }

  static Rect grow(Rect rect, float amount)
  {
    return shrink(rect, -amount, -amount);
  }

  static Rect fullscreen()
  {
    return new Rect(0, 0, Applet.width, Applet.height);
  }

  PVector position()
  {
    return new PVector(x, y);
  }

  void setPosition(PVector pos)
  {
    x = pos.x;
    y = pos.y;
  }

  Rect copy()
  {
    return new Rect(x, y, w, h);
  }

  // Is (x, y) within the rect?
  boolean contains(float x, float y)
  {
    return x > this.x && x < this.x + w && y > this.y && y < this.y + h;
  }

  // Just draw the rect
  void draw()
  {
    Applet.get().rect(x, y, w, h);
  }

  void draw(float cornerRadius)
  {
    Applet.get().rect(x, y, w, h, cornerRadius);
  }

  // === Center functions === //

  float centerX()
  {
    return x + w / 2;
  }

  float centerY()
  {
    return y + h / 2;
  }

  PVector center()
  {
    return new PVector(centerX(), centerY());
  }

  void setCenterX(float centerX)
  {
    x = centerX - w / 2;
  }

  void setCenterY(float centerY)
  {
    y = centerY - h / 2;
  }

  void setCenter(PVector center)
  {
    setCenterX(center.x);
    setCenterY(center.y);
  }

  Rect changeCenterX(float change)
  {
    setCenterX(centerX() + change);
    return this;
  }

  Rect changeCenterY(float change)
  {
    setCenterY(centerY() + change);
    return this;
  }

  Rect setWidth(float change)
  {
    w = change;
    return this;
  }

  Rect setHeight(float change)
  {
    h = change;
    return this;
  }

  Rect changeWidth(float change)
  {
    w += change;
    return this;
  }

  Rect changeHeight(float change)
  {
    h += change;
    return this;
  }
}


/*

 Math Functions
 Author: Evan Daveikis
 Written for: RayTracedGame
 Written: October 2023
 Modified: November 14, 2023
 
 */
// =====================================  Begin Previously Written Code


static class Maths
{
  static int sign(float f) // Returns the sign of F
  {
    if (f < 0) return -1;
    if (f > 0) return 1;
    return 0;
  }

  static PVector invert(PVector p) // Inverts a vector (I hate PVector semantics, I loooove unity Vector3s so much more now)
  {
    return new PVector(0, 0, 0).sub(p);
  }

  static float saturate(float value) // clamp(value, 0, 1);
  {
    return constrain(value, 0f, 1f);
  }

  static float sqrMag(PVector v) // Square magnitude of a vector (cheaper than v.mag(), avoids a sqrt)
  {
    return v.x * v.x + v.y * v.y + v.z * v.z;
  }

  static float sqrDist(PVector a, PVector b) // Square distance (cheap)
  {
    return sqrMag(a.copy().sub(b));
  }

  // =====================================  End Previously Written Code

  static boolean within(float value, float target, float fuzziness)
  {
    return abs(target - value) < fuzziness;
  }

  // Returns the index-th vertex of an n-sided polygon
  static PVector getVertex(int index, int n)
  {
    // Handle cases where n < 3
    if (n <= 0) return new PVector(0, 0); // Center
    if (n == 2) return new PVector(index == 0 ? 1 : -1, 0); // Left or right

    // Not looking this up, let's see if my math is up to par
    // EDIT: My math was not up to par
    /*
    int interiorAngle = (n - 2) * 180; // Tri n=3 a=180, quad n=4 a=360
     float anglePer = interiorAngle / (float)n;
     float angle = index * anglePer;
     */
    // Take 2
    // EDIT: Much better lol
    // idk what I was doing before
    float divisions = 360.0 / n;
    float angle = index * divisions;
    float rads = radians(angle - 90);
    return new PVector(cos(rads), sin(rads));
  }
}




/*

 Bit utilities
 Author: Evan Daveikis
 Written for: SpaceInvaders
 Used/Updated in: RayTracedGame
 Written: September/October 2023
 Modified: November 14, 2023
 
 */
// =====================================  Begin Previously Written Code

static class BitUtils
{
  static void drawBitmap(int bitmap, int numBits, float x, float y, float boxSize)
  {
    // Draw whatever bits are set in the bitmap
    // Graphical settings (fill() etc) should be set beforehand

    for (int i = 0; i < numBits; i++)
    {
      // Draw a rect if the bit is set
      if (isBitSet(bitmap, i))
      {
        // Reverse i because bitmaps are backwards
        Applet.get().rect(x + i * boxSize, y, boxSize, boxSize);
      }
    }
  }

  static int numberOfBitsSet(int mask)
  {
    int count = 0;

    for (int i = 0; i < 32; i++)
    {
      // Just count through all the bits, seeing how many are set (1)
      if (isBitSet(mask, i))
        count++;
    }

    return count;
  }

  // Returns true if the bit at bitIndex in mask is 1
  static boolean isBitSet(int mask, int bitIndex)
  {
    //i.e 10011 checking if index 1 is set
    // 10011
    // 00010 <- 1 << 1
    // &
    // 00010 > 0 therefore set

    return (mask & (1 << bitIndex)) > 0; // May not work for 32nd bit?
    // Two's compliment shenanigans or smth
  }

  // Returns mask with the given bit set (1)
  static int setBit(int mask, int bitIndexToSet)
  {
    // OR with the mask of bitIndexToSet
    return mask | (1 << bitIndexToSet);
  }

  // Returns mask with the given bit cleared (0)
  static int clearBit(int mask, int bitIndexToClear)
  {
    // AND with the inverse mask of bitIndexToClear
    return mask & ~(1 << bitIndexToClear);
  }

  // Returns mask with the given bit flipped
  static int toggleBit(int mask, int bitIndex)
  {
    if (isBitSet(mask, bitIndex))
      return clearBit(mask, bitIndex);
    return setBit(mask, bitIndex);
  }
}


// =====================================  End Previously Written Code
