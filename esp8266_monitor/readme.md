# Prepping the ESP8266

This code runs on NodeMCU. You need the following modules compiled in:

- `ws2812`
- `net`
- `WiFi`
- `CJSON`
- `http`
- `enduser_setup`

The easiest way to get firmware is to use the
[NodeMCU custom builder](https://nodemcu-build.com/).

Download [esptool.py](https://github.com/espressif/esptool).

Connect to your ESP8266 using an FTDI cable and identify the serial port. In my
case it was `/dev/tty.usbserial-FTHFO3J5` so that's what I'l use in my examples.
My firmware is `nodemcu-master-12-modules-2017-03-01-02-08-28-float.bin`.

Run the following two commands to flash NodeMCU onto the esp8266:
```
esptool.py --port /dev/tty.usbserial-FTHFO3J5 erase_flash
esptool.py --port /dev/tty.usbserial-FTHFO3J5 write_flash -fm dio -fs 8m 0x00000 nodemcu-master-12-modules-2017-03-01-02-08-28-float.bin
```

See [the NodeMCU docs](https://nodemcu.readthedocs.io/en/master/en/flash/) for
more info.

## What's left

The following things are left to do:

- Debug `bamboo.lua` and make sure it works as expected
- Create `init.lua`
  - Trigger end user setup portal on button hold/press
  - Once on a network, start timer to ping bamboo