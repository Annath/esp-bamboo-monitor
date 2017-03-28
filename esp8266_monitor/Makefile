flash:
	esptool.py --port $(SERIAL_PORT) erase_flash
	esptool.py --port $(SERIAL_PORT) write_flash -fm dio -fs 8m 0x00000 $(FIRMWARE_BIN)