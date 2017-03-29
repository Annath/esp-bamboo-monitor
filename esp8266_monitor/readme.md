# ESP Bamboo Build Monitor

This project is a build monitor that runs entirely on an ESP8266 wifi SoC. For prototyping I used an [AdaFruit ESP8266 Huzzah breakout board](https://www.adafruit.com/products/2471) and [NeoPixel Stick](https://www.adafruit.com/products/1426).

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
SERIAL_PORT=/dev/tty.usbserial-FTHFO3J5 FIRMWARE_BIN=nodemcu-master-12-modules-2017-03-01-02-08-28-float.bin make flash
```

See [the NodeMCU docs](https://nodemcu.readthedocs.io/en/master/en/flash/) for more info.

## Gotchas

The pin numbers are screwed up in NodeMCU vs what's printed on the Huzzah breakout board. See [this github comment](https://github.com/esp8266/Arduino/issues/584#issuecomment-123715951) for more info.

## What's left

- Figure out power supplies
- Fork into own repo
