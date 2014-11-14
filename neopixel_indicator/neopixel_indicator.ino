#include <Adafruit_NeoPixel.h>

#define NEOPIXEL_PIN 16
#define NEOPIXEL_NUM_PIXELS 30

typedef enum
{
  UP,
  DOWN,
} AnimationDirection;

typedef void (*AnimationHandler)(void);

// The actual animations
void animateNothing(void);
void animateHistory(void);
void animateBreathing(void);
void animateScanner(void);

// animation specific helper functions
void setScanner(uint32_t index);
void populatescannerAnimationValueTable(uint32_t baseColor);

// generic helper functions
void setAllPixels(uint32_t color);
void resetAnimation(void);

Adafruit_NeoPixel strip = Adafruit_NeoPixel(NEOPIXEL_NUM_PIXELS, NEOPIXEL_PIN, NEO_GRB + NEO_KHZ800);
AnimationHandler animate = animateNothing;

// some common useful variables for the animations
uint32_t nextTickTime = 0;
uint32_t tickIndex = 0;
AnimationDirection animationDirection = UP;

// and some animation specific variables
uint32_t breathingAnimationColorMask;
uint8_t scannerAnimationValueTable[3][4];
uint8_t buildHistory[NEOPIXEL_NUM_PIXELS]; // 0 for a passed build, 1 for failed, 2 for no data
uint8_t twinkleIndex = 0;

void setup(void)
{
  Serial.begin(9600);
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
}

void loop(void)
{
  // Check for a command
  if (Serial.available())
  {
    char cmd = Serial.read();
    if (cmd == 'x' || cmd == 'i')
    {
      resetAnimation();
      animate = animateNothing;
    }
    else if (cmd == 'p' || cmd == 's')
    {
      resetAnimation();
      breathingAnimationColorMask = 0x00ff00;
      animate = animateBreathing;
    }
    else if (cmd == 'f')
    {
      resetAnimation();
      breathingAnimationColorMask = 0xff0000;
      animate = animateBreathing;
    }
    else if (cmd == 'r')
    {
      resetAnimation();
      populatescannerAnimationValueTable(0x0000ff);
      animate = animateScanner;
    }
    else if (cmd == 'h')
    {
      // idle, parse build stats and show
      memset(buildHistory, 2, NEOPIXEL_NUM_PIXELS);
      uint8_t i;
      for (i = 0; (i < NEOPIXEL_NUM_PIXELS) && Serial.available(); i++)
      {
        buildHistory[i] = (Serial.read() - 48);
      }
      resetAnimation();
      animate = animateHistory;
    }
  }
  // run the current animation
  animate();
}

// set all pixels to the same value
void setAllPixels(uint32_t color)
{
  uint8_t i = 0;
  for (i = 0; i < strip.numPixels(); i++)
  {
    strip.setPixelColor(i, color);
  }
  strip.show();
}

// reset the strip to 'off' and reset the animation global variables
void resetAnimation(void)
{
  setAllPixels(0);
  nextTickTime = 0;
  tickIndex = 0;
  animationDirection = UP;
}

// This is the bootup animation, it should only appear when we reset. It's useful to let us know that the reset completed.
void animateNothing(void)
{
  setAllPixels(0x080808);
}

// This will eventually show a quick overview of our build history with red LEDs for failed builds and green for passed.
void animateHistory(void)
{
  if (millis() >= nextTickTime)
  {
    uint8_t i = 0;
    for (i = 0; i < strip.numPixels(); i++)
    {
      uint8_t twinkle = 0;
      if (i == twinkleIndex)
      {
        Serial.print("Twinkling at index ");
        Serial.print(twinkleIndex);
        Serial.print(" by amount ");
        Serial.println(tickIndex);
        twinkle = tickIndex;
      }
      uint8_t r;
      uint8_t g;
      uint8_t b;
      switch (buildHistory[i])
      {
        case 0:
          r = 0x00;
          g = 0xff;
          b = 0x00;
          break;
        case 1:
          r = 0xff - twinkle;
          g = 0x00;
          b = 0x00;
          break;
        case 2:
          r = 0x05;
          g = 0x05;
          b = 0x05;
          break;
      }
      strip.setPixelColor(i, r, g, b);
    }
    strip.show();
    nextTickTime = millis() + 75;
    tickIndex++;
    if (tickIndex == 128)
    {
      tickIndex = 0;
      twinkleIndex = (twinkleIndex + 1) % NEOPIXEL_NUM_PIXELS;
    }
  }
}

// This gives us a smooth "breathing" effect
void animateBreathing(void)
{
  if (millis() >= nextTickTime)
  {
    uint32_t colorValue = ((tickIndex << 16) | (tickIndex << 8) | (tickIndex)) & breathingAnimationColorMask;
    setAllPixels(colorValue);
    
    Serial.print("Setting color to 0x");
    Serial.print(colorValue, HEX);
    Serial.print(" at index ");
    Serial.println(tickIndex);
    
    if (tickIndex == 255)
    {
      nextTickTime = millis() + 1;
      animationDirection = DOWN;
    }
    else if (tickIndex > 150 && tickIndex < 255)
    {
      nextTickTime = millis() + 4;
    }
    else if ((tickIndex > 125) && (tickIndex < 151)) {
      nextTickTime = millis() + 5;
    }
    else if ((tickIndex > 100) && (tickIndex < 126)) {
      nextTickTime = millis() + 7;
    }
    else if ((tickIndex > 75) && (tickIndex < 101)) {
      nextTickTime = millis() + 10;
    }
    else if ((tickIndex > 50) && (tickIndex < 76)) {
      nextTickTime = millis() + 14;
    }
    else if ((tickIndex > 25) && (tickIndex < 51)) {
      nextTickTime = millis() + 18;
    }
    else if (tickIndex < 26 && tickIndex > 0) {
      nextTickTime = millis() + 19;
    }
    else if (tickIndex == 0)
    {
      nextTickTime = millis() + 30;
      animationDirection = UP;
    }
    
    animationDirection == UP ? tickIndex++ : tickIndex--;
  }
}

void animateScanner(void)
{
  if (millis() >= nextTickTime)
  {
    setScanner(tickIndex);
    Serial.print("Scanning... ");
    Serial.println(tickIndex);
    
    if (tickIndex == (0 - 4))
    {
      animationDirection = UP;
      nextTickTime = millis() + 200;
    }
    else if (tickIndex == (strip.numPixels() + 3))
    {
      animationDirection = DOWN;
      nextTickTime = millis() + 200;
    }
    else
    {
      nextTickTime = millis() + 75;
    }
    
    animationDirection == UP ? tickIndex++ : tickIndex--;
  }
}

void setScanner(uint32_t index)
{
  for (uint8_t k = 0; k < strip.numPixels(); k++)
  {
    strip.setPixelColor(k, 0, 0, 0);
    if (k == index)
    {
      strip.setPixelColor(k,
        scannerAnimationValueTable[0][0],
        scannerAnimationValueTable[1][0],
        scannerAnimationValueTable[2][0]);
    }
    else if (k == (index + 1) || k == (index - 1))
    {
      strip.setPixelColor(k,
        scannerAnimationValueTable[0][1],
        scannerAnimationValueTable[1][1],
        scannerAnimationValueTable[2][1]);
    }
    else if (k == (index + 2) || k == (index- 2))
    {
      strip.setPixelColor(k,
        scannerAnimationValueTable[0][2],
        scannerAnimationValueTable[1][2],
        scannerAnimationValueTable[2][2]);
    }
    else if (k == (index+ 3) || k == (index- 3))
    {
      strip.setPixelColor(k,
        scannerAnimationValueTable[0][3],
        scannerAnimationValueTable[1][3],
        scannerAnimationValueTable[2][3]);
    }
  }
  strip.show();
}

void populatescannerAnimationValueTable(uint32_t baseColor)
{
  scannerAnimationValueTable[0][0] = (baseColor >> 16) & 0x000000ff;
  scannerAnimationValueTable[1][0] = (baseColor >> 8) & 0x000000ff;
  scannerAnimationValueTable[2][0] = baseColor & 0x000000ff;
  
  uint8_t i;
  for (i = 0; i < 4; i++)
  {
    scannerAnimationValueTable[i][1] = (scannerAnimationValueTable[i][0] >> 1);
    scannerAnimationValueTable[i][2] = (scannerAnimationValueTable[i][0] >> 2);
    scannerAnimationValueTable[i][3] = scannerAnimationValueTable[i][0] >> 3;
  }
  
  Serial.println("Color table:\nr\tg\tb");
  Serial.print(scannerAnimationValueTable[0][0]);
  Serial.print("\t");
  Serial.print(scannerAnimationValueTable[1][0]);
  Serial.print("\t");
  Serial.println(scannerAnimationValueTable[2][0]);
  
  Serial.print(scannerAnimationValueTable[0][1]);
  Serial.print("\t");
  Serial.print(scannerAnimationValueTable[1][1]);
  Serial.print("\t");
  Serial.println(scannerAnimationValueTable[2][1]);
  
  Serial.print(scannerAnimationValueTable[0][2]);
  Serial.print("\t");
  Serial.print(scannerAnimationValueTable[1][2]);
  Serial.print("\t");
  Serial.println(scannerAnimationValueTable[2][2]);
  
  Serial.print(scannerAnimationValueTable[0][3]);
  Serial.print("\t");
  Serial.print(scannerAnimationValueTable[1][3]);
  Serial.print("\t");
  Serial.println(scannerAnimationValueTable[2][3]);
}

