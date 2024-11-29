import java.util.Arrays;

static class Applet
{
  // This exists so I can access it even in static classes
  // A truly global variable
  private static PApplet instance;
  static final int width = 1280;
  static final int height = 1024;

  static PApplet get()
  {
    return instance;
  }

  static void init(PApplet applet)
  {
    instance = applet;
  }

  // Stops the app (useful for exceptions);
  static void stop()
  {
    //instance.stop(); // Not sure if this actually works? Documentation is empty
    exit();
  }

  static void exit()
  {
    instance.exit();
  }

  static void exit(String reason)
  {
    println(reason);
    exit();
  }

  static PImage loadImage(String path)
  {
    return instance.loadImage(path);
  }
}

static class JSON
{
  // Returns the parsed value, or null if not found
  static <T extends Enum<T>> T getEnum(Class<T> enumType, String json)
  {
    if (json == null || json.isBlank())
      return null;

    try
    {
      return Enum.valueOf(enumType, json.toUpperCase());
    }
    catch (IllegalArgumentException e)
    {
      // Return null instead of crashing program; we will just not load this card
      return null;
    }
  }

  // Returns the parsed value, or defaultValue if not found
  static <T extends Enum<T>> T getEnum(Class<T> enumType, String json, T defaultValue)
  {
    T val = getEnum(enumType, json);
    return val == null ? defaultValue : val;
  }

  // Returns the parsed value of key, or null if not found/invalid
  static <T extends Enum<T>> T getEnum(Class<T> enumType, JSONObject object, String key)
  {
    return getEnum(enumType, object.getString(key));
  }

  // Returns the parsed value of key, or defaultValue if not found/invalid
  static <T extends Enum<T>> T getEnum(Class<T> enumType, JSONObject object, String key, T defaultValue)
  {
    return getEnum(enumType, object.getString(key), defaultValue);
  }

  // Wack and complicated, let's just do it manually in the Connection/Effect classes
  /*
  static <T extends JSONSerializable<T>> T get(JSONObject obj, String key)
   {
   if (!obj.hasKey(key))
   return null;
   return new T().fromJSON(obj);
   }
   */
}

/*
static interface JSONSerializable<T extends JSONSerializable<T>>
 {
 JSONObject toJSON();
 T fromJSON(JSONObject obj);
 }
 */


// Just a wrapper around a PVector for tile based stuff
static class PVectorInt
{
  PVector vec;

  PVectorInt(PVector vec)
  {
    this.vec = new PVector(round(vec.x), round(vec.y));
  }

  PVectorInt(int x, int y)
  {
    this(new PVector(x, y));
  }

  PVectorInt(float x, float y)
  {
    this(new PVector(x, y));
  }

  PVectorInt()
  {
    this(new PVector(0, 0));
  }

  int x()
  {
    return round(vec.x);
  }

  int y()
  {
    return round(vec.y);
  }

  // Returns a normal PVector with rounded values (different from vec)
  PVector intVec()
  {
    return new PVector(x(), y());
  }

  PVectorInt copy()
  {
    return new PVectorInt(vec.copy());
  }

  PVectorInt add(int x, int y)
  {
    vec.add(new PVector(x, y));
    return this;
  }

  PVectorInt add(PVectorInt vec)
  {
    this.vec.add(vec.vec);
    return this;
  }

  PVectorInt add(PVector vec)
  {
    this.vec.add(vec);
    return this;
  }

  PVectorInt sub(int x, int y)
  {
    vec.sub(new PVector(x, y));
    return this;
  }

  PVectorInt sub(PVectorInt vec)
  {
    this.vec.sub(vec.vec);
    return this;
  }

  PVectorInt sub(PVector vec)
  {
    this.vec.sub(vec);
    return this;
  }

  float dist(PVectorInt other)
  {
    return intVec().dist(other.intVec());
  }

  boolean adjacentTo(PVectorInt other)
  {
    // Just in case floats are a bit iffy
    return Maths.within(dist(other), 1, 0.1);
  }

  // Returns true if this vector has a length of 1 and is not diagonal
  boolean isDirection()
  {
    int x = abs(x());
    int y = abs(y());
    return (x == 1 && y == 0) || (x == 0 && y == 1);
  }

  // Returns true if this vector is not diagonal
  boolean isCardinal()
  {
    return (x() == 0) != (y() == 0);
  }

  // Retursn the direction of this vector (if this is a direction)
  Direction getDirection()
  {
    return Direction.fromOffset(this);
  }

  // Returns true if this vector is on the same X or Y axis as other
  boolean alignedWith(PVectorInt other)
  {
    return x() == other.x() || y() == other.y();
  }

  Direction dir(PVectorInt other)
  {
    // Make sure they are in a line
    if (!alignedWith(other))
      return null;
    PVectorInt dir = other.copy().sub(this);
    // Set the length to one
    dir.vec.normalize();
    return dir.getDirection();
  }



  /*
  Credit:
   Reason: Idk how to implement a custom hashcode function lol
   https://stackoverflow.com/questions/16377926/how-to-write-hashcode-method-for-a-particular-class
   */
  @Override
    int hashCode() {
    return Arrays.hashCode(new Object[]{ x(), y() });
  }


  /*
  Credit: Lombo
   Reason: Didn't know the proper way to override equals() in java
   https://stackoverflow.com/questions/2265503/why-do-i-need-to-override-the-equals-and-hashcode-methods-in-java
   */
  @Override
    boolean equals(final Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    final PVectorInt other = (PVectorInt) obj;
    return x() == other.x() && y() == other.y();
  }
}


/*

 Time
 Author: Evan Daveikis
 Written for: RayTracedGame
 Written: October 2023
 Modified: November 14, 2023
 
 */
// =====================================  Begin Previously Written Code

static class Time
{
  static float deltaTime; // Unity convention ig, also not a raytracer anymore, don't need clamping lol
  //float dt; // Delta time (clamped, for gameplay)
  //float dt_actual; // Delta time (raw, for fps display)
  private static int lastMS; // The millisecond of the last frame

  //float CONST_MAX_DT = 0.1; // 100 ms

  static void update()
  {
    int mil = Applet.get().millis();
    //dt_actual = (mil - lastMS) / 1000f;
    deltaTime = (mil - lastMS) / 1000f;
    lastMS = mil;
    //dt = min(dt_actual, CONST_MAX_DT);
  }
}

// =====================================  End Previously Written Code
