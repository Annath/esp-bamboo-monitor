# ESP Bamboo Build Monitor

This project is a build monitor that runs entirely on an ESP8266 wifi SoC. For prototyping I used an [AdaFruit ESP8266 Huzzah breakout board][huzzah] and [NeoPixel Stick](https://www.adafruit.com/products/1426).

## Prepping the ESP8266

This code runs on NodeMCU. You need the following modules compiled in:

- `ws2812`
- `net`
- `WiFi`
- `CJSON`
- `http`
- `enduser_setup`
- `encoder`

The easiest way to get firmware is to use the [NodeMCU custom builder](https://nodemcu-build.com/).

Download [esptool.py](https://github.com/espressif/esptool).

Connect to your ESP8266 using an FTDI cable and identify the serial port. In my case it was `/dev/tty.usbserial-FTHFO3J5` so that's what I'l use in my examples. My firmware is `nodemcu-master-12-modules-2017-03-01-02-08-28-float.bin`.

Run the following two commands to flash NodeMCU onto the esp8266:
```
esptool.py --port /dev/tty.usbserial-FTHFO3J5 erase_flash
esptool.py --port /dev/tty.usbserial-FTHFO3J5 write_flash -fm dio -fs 8m 0x00000 nodemcu-master-12-modules-2017-03-01-02-08-28-float.bin
```
or if you're lazy and have make,
```
SERIAL_PORT=/dev/tty.usbserial-FTHFO3J5 \
FIRMWARE_BIN=nodemcu-master-12-modules-2017-03-01-02-08-28-float.bin \
make flash
```

See [the NodeMCU docs](https://nodemcu.readthedocs.io/en/master/en/flash/) for more info.

## Gotchas

The pin numbers are screwed up in NodeMCU vs what's printed on the Huzzah breakout board. See [this github comment](https://github.com/esp8266/Arduino/issues/584#issuecomment-123715951) for more info.

## Power

Whatever you use to power this project, you need at least 750 mA of continuous discharge. The [Huzzah breakout][huzzah] runs on single cell LiPo voltage or 5V pretty happily.

I prototyped battery power using a [SparkFun 850mAh Lithium Ion battery](https://www.sparkfun.com/products/13854) and a [SparkFun LiPo Charger Basic](https://www.sparkfun.com/products/10217) to show it was possible.

With the [Huzzah breakout][huzzah], you can power if from 5V wall power as well, but you need a level shifter. I prototyped with an SN74AHCT125 buffer. Power the buffer, the Huzzah, and the LEDs from the same 5V output, and route the WS2812 control signal from the Huzzah through the buffer to shift it up to 5V before connecting it to the LED strip.

## What's left

1. Battery measurement when running on battery power
1. Design a PCB?

[huzzah]: https://www.adafruit.com/products/2471
