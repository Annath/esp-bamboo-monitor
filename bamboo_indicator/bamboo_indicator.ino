#define LED_PIN_RED   8
#define LED_PIN_GREEN 9
#define LED_PIN_BLUE  10
#define PULSE_RATE_MS 30

typedef enum {
  INACTIVE = 'i',
  BUILD_RUNNING = 'r',
  BUILD_FAILED = 'f',
  BUILD_SUCCEEDED = 's',
} BuildState;

uint8_t modeCmd[] = "mode ";

uint8_t buffer[50];
uint8_t bufferIndex = 0;

uint8_t blue_value = 255; // 255 = fully off, 0 = fully on
int8_t blue_increment = -1; // -1 or 1 so we can control up/down

BuildState state = INACTIVE; // startup INACTIVE so the LED is off completely

void loop(void)
{
  // Check our serial line
  if (Serial.available() > 0)
  {
    char c = Serial.read();
    // load the character into the buffer for future comparison and increment the buffer index
    buffer[bufferIndex++] = c;
    // this should really never happen, but just in case it does, roll the buffer back to zero
    if (bufferIndex == 50) bufferIndex = 0;
    // If it's a printable character, do local echo so if someone is typing commands in directly they can see them
    if (c >= 32 && c <= 126) Serial.print(c);
    // aaaaaand CR is our cue to process the command
    if (c == '\r')
    {
      // newline for formatting
      Serial.println("");
      // reset the buffer index
      bufferIndex = 0;
      // check to see if we got our mode command
      if (memcmp(modeCmd, buffer, 5) == 0)
      {
        // there are only four valid modes, so we make sure the entered mode is valid
        if (buffer[5] == INACTIVE ||
            buffer[5] == BUILD_RUNNING ||
            buffer[5] == BUILD_FAILED ||
            buffer[5] == BUILD_SUCCEEDED)
        {
          state = (BuildState)(buffer[5]);
          Serial.print("Setting mode to ");
          Serial.println((char)state);
        }
        else
        {
          Serial.println("Invalid mode");
        }
      }
      else
      {
        Serial.println("Invalid command.");
      }
    }
  }
  
  switch (state)
  {
    case (INACTIVE):
      analogWrite(LED_PIN_RED, 255);
      analogWrite(LED_PIN_GREEN, 255);
      analogWrite(LED_PIN_BLUE, 255);
      break;
    case (BUILD_RUNNING):
      // pulse the blue LED to indicate that a build is running
      if ((millis() % PULSE_RATE_MS) == 0)
      {
        // bounce back and forth between 0 and 255 to give a nice pulsing
        blue_value += blue_increment;
        if (blue_value == 255)
        {
          blue_increment = -1;
        }
        else if (blue_value == 0)
        {
          blue_increment = 1;
        }
        
        analogWrite(LED_PIN_RED, 255);
        analogWrite(LED_PIN_GREEN, 255);
        analogWrite(LED_PIN_BLUE, blue_value);
      }
      break;
    case (BUILD_FAILED):
      // Solid red for failure
      analogWrite(LED_PIN_RED, 0);
      analogWrite(LED_PIN_GREEN, 255);
      analogWrite(LED_PIN_BLUE, 255);
      break;
    case (BUILD_SUCCEEDED):
      // Solid green for success
      analogWrite(LED_PIN_RED, 255);
      analogWrite(LED_PIN_GREEN, 0);
      analogWrite(LED_PIN_BLUE, 255);
      break;
  }
}

void setup(void)
{
  pinMode(LED_PIN_RED, OUTPUT);
  pinMode(LED_PIN_GREEN, OUTPUT);
  pinMode(LED_PIN_BLUE, OUTPUT);

  // Init all LEDs to off
  analogWrite(LED_PIN_RED, 255);
  analogWrite(LED_PIN_GREEN, 255);
  analogWrite(LED_PIN_BLUE, 255);
  
  Serial.begin(9600);
}
