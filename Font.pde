//Code from 'Ray Traced Game' Object Oriented Toy by Evan Daveikis 991721245
//Fall 2023 GAME12805
//Word extension from Professor Kit Barry
//Added an extension copying the numbers-to-letters idea, so we can just throw
//strings at this instead of having to manually assemble the letter bitmaps

Font Font = new Font(); // Global accessor

class Font
{
  // Draw an array of letters (returning the new x coordinate)
  float draw(float x, float y, float size, Letter... letters)
  {
    if (letters == null || letters.length == 0)
      return x;

    for (Letter l : letters)
    {
      // Draw each letter
      x = l.draw(x, y, size) + size; // Add 1 pixel space between letters
    }

    return x;
  }

  // Both of these are just shorthands for the number constructors (same thing)
  Number number(int number)
  {
    return new Number(number);
  }

  Number number(float number, int decimals)
  {
    return new Number(number, decimals);
  }
  
  //Kit's code to do the same for strings
  Word word(String word){
    return new Word(word);
  }
}

class Letter
{
  int[] bitmaps; // This character's bitmap
  int width; // How many bits wide

  Letter(int width, int... bitmaps)
  {
    this.width = width;
    this.bitmaps = bitmaps;
  }

  // Draw all the bitmaps top to bottom
  float draw(float x, float y, float size)
  {
    for (int i = 0; i < bitmaps.length; i++)
    {
      drawBitmap(bitmaps[i], width, x, y + i * size, size);
    }

    return x + width * size; // x + size of letter in pixels
  }
}

//Sneaky class added by Kit to turn strings into letters
class Word extends Letter {
  ArrayList<Letter> letters; //stores the letters
  
  //constructor: does most of the work turning this into a list of bitmaps
  Word(String word){
    super(0, 0); //call the base constructor with nothing
    word = word.toLowerCase(); //make the letters all lower-case to simplify things
    letters = new ArrayList<Letter>();
    //loop through each character in the string and add the Letter version to our list
    for(int i = 0; i < word.length(); i++){
      char letter = word.charAt(i);
      letters.add(letterFromChar(letter));
    }
  }
  
  //Evan's function, loops through the list of bitmaps we made, drawing them
  //(this gets called by Font.draw because it's overriding the base function ;-)
  // Hijack the draw function to draw a bunch of letters instead >:)
  float draw(float x, float y, float size)
  {
    for (Letter l : letters)
    {
      // Draw each letter
      x = l.draw(x, y, size) + size; // Add 1 pixel space between digits
    }

    return x;
  }
  
}

//sorry :C
Letter letterFromChar(char c){
 
   if(c == 'a')  return _a;
   if(c == 'b')  return _b;
   if(c == 'c')  return _c;
   if(c == 'd')  return _d;
   if(c == 'e')  return _e;
   if(c == 'f')  return _f;
   if(c == 'g')  return _g;
   if(c == 'h')  return _h;
   if(c == 'i')  return _i;
   if(c == 'j')  return _j;
   if(c == 'k')  return _k;
   if(c == 'l')  return _l;
   if(c == 'm')  return _m;
   if(c == 'n')  return _n;
   if(c == 'o')  return _o;
   if(c == 'p')  return _p;
   if(c == 'q')  return _q;
   if(c == 'r')  return _r;
   if(c == 's')  return _s;
   if(c == 't')  return _t;
   if(c == 'u')  return _u;
   if(c == 'v')  return _v;
   if(c == 'w')  return _w;
   if(c == 'x')  return _x;
   if(c == 'y')  return _y;
   if(c == 'z')  return _z;
   if(c == ',')  return _comma;
   if(c == '.')  return _period;
   if(c == '-')  return _dash;
   if(c == '!')  return _exclam;
   if(c == '(')  return _lParen;
   if(c == ')')  return _rParen;
   if(c == '/')  return _slash;
   if(c == '+')  return _plus;
   if(c == '0')  return _0;
   if(c == '1')  return _1;
   if(c == '2')  return _2;
   if(c == '3')  return _3;
   if(c == '4')  return _4;
   if(c == '5')  return _5;
   if(c == '6')  return _6;
   if(c == '7')  return _7;
   if(c == '8')  return _8;
   if(c == '9')  return _9;
   
 return _space; 
}

//end of Kit's code

// Sneaky class to hijack the Letter draw() to draw multi-character numbers
class Number extends Letter
{
  // We don't even care about our inherited bitmaps or width
  // (if only we had interfaces...)
  ArrayList<Letter> digits; // List of digits to display

  // Returns a whole number as a displayable thing (a Letter in disguise)
  Number(int number)
  {
    super(0, 0);
    digits = new ArrayList<Letter>();
    fillDigits(number);
  }

  // Same as above but for decimals
  Number(float number, int decimalDigits)
  {
    super(0, 0);
    digits = new ArrayList<Letter>();

    // Numbers are added back to front, so do decimals first
    int decimalBase10 = (int)pow(10, decimalDigits);
    float decimals = (number * decimalBase10) % decimalBase10;
    fillDigits((int)abs(decimals));

    digits.add(0, _period); // The dot

    fillDigits((int)number); // The rest of the number
  }

  void fillDigits(int number)
  {
    // This function is so dirty

    // Store if the number is negative so we can add the dash later
    boolean negative = number < 0;

    if (negative) // Invert it
      number = -number;

    while (number > 9) // Fill until less than 10
      number = fillDigit(number, digits); // Decreases the number
    fillDigit(number, digits); // Fill the last one

    if (negative) // Add the dash at the front
      digits.add(0, _dash);
  }

  int fillDigit(int number, ArrayList<Letter> digitList)
  {
    // Adds the corresponding letter and divides
    digitList.add(0, letterFromDigit(number % 10));
    return number / 10;
  }

  Letter letterFromDigit(int number)
  {
    // I don't know if we can use switch statements,
    //  so a million "if"s it is
    if (number == 0) return _0;
    if (number == 1) return _1;
    if (number == 2) return _2;
    if (number == 3) return _3;
    if (number == 4) return _4;
    if (number == 5) return _5;
    if (number == 6) return _6;
    if (number == 7) return _7;
    if (number == 8) return _8;
    if (number == 9) return _9; // Yuck
    return _space; // Just an empty letter
  }

  // Hijack the draw function to draw a bunch of letters instead >:)
  float draw(float x, float y, float size)
  {
    for (Letter l : digits)
    {
      // Draw each digit
      x = l.draw(x, y, size) + size; // Add 1 pixel space between digits
    }

    return x;
  }
}

// Everything beneath here is just letter bitmaps
// They are global variables with short names to be easy to pass into functions

// Hardcoded
int fontPixelWidth = 5; // In bits

// Letters
Letter _a = new Letter(fontPixelWidth,
  0b01110,
  0b10001,
  0b10001,
  0b11111,
  0b10001,
  0b10001,
  0b10001
  );

Letter _b = new Letter(fontPixelWidth,
  0b11110,
  0b10001,
  0b10001,
  0b11110,
  0b10001,
  0b10001,
  0b11110
  );

Letter _c = new Letter(fontPixelWidth,
  0b01110,
  0b10001,
  0b10000,
  0b10000,
  0b10000,
  0b10001,
  0b01110
  );

Letter _d = new Letter(fontPixelWidth,
  0b11110,
  0b10001,
  0b10001,
  0b10001,
  0b10001,
  0b10001,
  0b11110
  );

Letter _e = new Letter(fontPixelWidth,
  0b11111,
  0b10000,
  0b10000,
  0b11110,
  0b10000,
  0b10000,
  0b11111
  );

Letter _f = new Letter(fontPixelWidth,
  0b11111,
  0b10000,
  0b10000,
  0b11110,
  0b10000,
  0b10000,
  0b10000
  );

Letter _g = new Letter(fontPixelWidth,
  0b01110,
  0b10001,
  0b10000,
  0b10111,
  0b10001,
  0b10001,
  0b01110
  );

Letter _h = new Letter(fontPixelWidth,
  0b10001,
  0b10001,
  0b10001,
  0b11111,
  0b10001,
  0b10001,
  0b10001
  );

Letter _i = new Letter(fontPixelWidth,
  0b01110,
  0b00100,
  0b00100,
  0b00100,
  0b00100,
  0b00100,
  0b01110
  );

Letter _j = new Letter(fontPixelWidth,
  0b11111,
  0b00100,
  0b00100,
  0b00100,
  0b10100,
  0b10100,
  0b01000
  );

Letter _k = new Letter(fontPixelWidth,
  0b10001,
  0b10001,
  0b10010,
  0b11100,
  0b10010,
  0b10001,
  0b10001
  );

Letter _l = new Letter(4,
  0b1000,
  0b1000,
  0b1000,
  0b1000,
  0b1000,
  0b1000,
  0b1111
  );

Letter _m = new Letter(fontPixelWidth,
  0b11011,
  0b10101,
  0b10101,
  0b10101,
  0b10001,
  0b10001,
  0b10001
  );

Letter _n = new Letter(fontPixelWidth,
  0b10001,
  0b11001,
  0b11001,
  0b10101,
  0b10011,
  0b10011,
  0b10001
  );

Letter _o = new Letter(fontPixelWidth,
  0b01110,
  0b10001,
  0b10001,
  0b10001,
  0b10001,
  0b10001,
  0b01110
  );

Letter _p = new Letter(fontPixelWidth,
  0b11110,
  0b10001,
  0b10001,
  0b11110,
  0b10000,
  0b10000,
  0b10000
  );

Letter _q = new Letter(fontPixelWidth,
  0b01110,
  0b10001,
  0b10001,
  0b10001,
  0b10101,
  0b10011,
  0b01110
  );

Letter _r = new Letter(fontPixelWidth,
  0b11110,
  0b10001,
  0b10001,
  0b11110,
  0b10100,
  0b10010,
  0b10001
  );

Letter _s = new Letter(fontPixelWidth,
  0b01110,
  0b10001,
  0b10000,
  0b01110,
  0b00001,
  0b10001,
  0b01110
  );

Letter _t = new Letter(fontPixelWidth,
  0b11111,
  0b00100,
  0b00100,
  0b00100,
  0b00100,
  0b00100,
  0b00100
  );

Letter _u = new Letter(fontPixelWidth,
  0b10001,
  0b10001,
  0b10001,
  0b10001,
  0b10001,
  0b10001,
  0b01110
  );

Letter _v = new Letter(fontPixelWidth,
  0b10001,
  0b10001,
  0b10001,
  0b10001,
  0b01010,
  0b01010,
  0b00100
  );

Letter _w = new Letter(fontPixelWidth,
  0b10001,
  0b10001,
  0b10001,
  0b10101,
  0b10101,
  0b10101,
  0b11011
  );

Letter _x = new Letter(fontPixelWidth,
  0b10001,
  0b10001,
  0b01010,
  0b00100,
  0b01010,
  0b10001,
  0b10001
  );

Letter _y = new Letter(fontPixelWidth,
  0b10001,
  0b10001,
  0b10001,
  0b01010,
  0b00100,
  0b00100,
  0b00100
  );

Letter _z = new Letter(fontPixelWidth,
  0b11111,
  0b00001,
  0b00010,
  0b00100,
  0b01000,
  0b10000,
  0b11111
  );


// Numbers
Letter _0 = new Letter(fontPixelWidth,
  0b01110,
  0b10001,
  0b10011,
  0b10101,
  0b11001,
  0b10001,
  0b01110
  );

Letter _1 = new Letter(fontPixelWidth,
  0b00100,
  0b01100,
  0b00100,
  0b00100,
  0b00100,
  0b00100,
  0b01110
  );

Letter _2 = new Letter(fontPixelWidth,
  0b01110,
  0b10001,
  0b00001,
  0b00110,
  0b01000,
  0b10000,
  0b11111
  );

Letter _3 = new Letter(fontPixelWidth,
  0b11111,
  0b00001,
  0b00010,
  0b00110,
  0b00001,
  0b10001,
  0b01110
  );

Letter _4 = new Letter(fontPixelWidth,
  0b00010,
  0b00110,
  0b01010,
  0b10010,
  0b11111,
  0b00010,
  0b00010
  );

Letter _5 = new Letter(fontPixelWidth,
  0b11111,
  0b10000,
  0b11110,
  0b00001,
  0b00001,
  0b10001,
  0b01110
  );

Letter _6 = new Letter(fontPixelWidth,
  0b01110,
  0b10001,
  0b10000,
  0b11110,
  0b10001,
  0b10001,
  0b01110
  );

Letter _7 = new Letter(fontPixelWidth,
  0b11111,
  0b00001,
  0b00010,
  0b00100,
  0b01000,
  0b01000,
  0b01000
  );

Letter _8 = new Letter(fontPixelWidth,
  0b01110,
  0b10001,
  0b10001,
  0b01110,
  0b10001,
  0b10001,
  0b01110
  );

Letter _9 = new Letter(fontPixelWidth,
  0b01110,
  0b10001,
  0b10001,
  0b01111,
  0b00001,
  0b10001,
  0b01110
  );


// Punctuation

Letter _space = new Letter(3,
  0
  );

Letter _comma = new Letter(3,
  0b000,
  0b000,
  0b000,
  0b000,
  0b000,
  0b100,
  0b100
  );

Letter _period = new Letter(3,
  0b000,
  0b000,
  0b000,
  0b000,
  0b000,
  0b110,
  0b110
  );

Letter _colon = new Letter(3,
  0b000,
  0b110,
  0b110,
  0b000,
  0b000,
  0b110,
  0b110
  );

Letter _apostrophe = new Letter(3,
  0b100,
  0b100,
  0b000,
  0b000,
  0b000,
  0b000,
  0b000
  );

Letter _quote = new Letter(4,
  0b1010,
  0b1010,
  0b0000,
  0b0000,
  0b0000,
  0b0000,
  0b0000
  );

Letter _exclam = new Letter(3,
  0b100,
  0b100,
  0b100,
  0b100,
  0b000,
  0b000,
  0b100
  );

Letter _dash = new Letter(3,
  0b000,
  0b000,
  0b000,
  0b111,
  0b000,
  0b000,
  0b000
  );

Letter _lParen = new Letter(3,
  0b001,
  0b010,
  0b010,
  0b010,
  0b010,
  0b010,
  0b001
  );

Letter _rParen = new Letter(3,
  0b100,
  0b010,
  0b010,
  0b010,
  0b010,
  0b010,
  0b100
  );

Letter _plus = new Letter(3,
  0b000,
  0b000,
  0b010,
  0b111,
  0b010,
  0b000,
  0b000
  );

Letter _slash = new Letter(3,
  0b001,
  0b001,
  0b010,
  0b010,
  0b010,
  0b100,
  0b100
  );

/*
  // Empty bitmap
 
 0b00000,
 0b00000,
 0b00000,
 0b00000,
 0b00000,
 0b00000,
 0b00000,
 
 */
