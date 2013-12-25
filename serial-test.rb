require 'serialport'

class IndicatorLed

  def initialize
    @sp = SerialPort.new("COM31", 9600)
    # @sp.flow_control = SerialPort::NONE
  end

  def setMode(mode)
    if (mode == 'i' or mode == 'r' or mode == 'f' or mode == 's') then
      # puts "mode #{mode}"
      @sp.write("mode #{mode}\r")
    end
  end

  def close
    @sp.close
  end

end

led = IndicatorLed.new

puts 'Setting mode to inactive'
led.setMode('i')
sleep(1)
puts 'Setting mode to running'
led.setMode('r')
sleep(15)
puts 'Setting mode to failed'
led.setMode('f')
sleep(5)
puts 'Setting mode to running'
led.setMode('r')
sleep(15)
puts 'Setting mode to succeeded'
led.setMode('s')
sleep(5)

led.close