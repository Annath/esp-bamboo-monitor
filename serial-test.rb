require 'serialport'

class IndicatorLed

  def initialize
    @sp = SerialPort.new("COM31", 9600)
    # @sp.flow_control = SerialPort::NONE
  end

  def setMode(mode)
    if (mode == 'i' or mode == 'r' or mode == 'f' or mode == 's') then
      puts "mode #{mode}"
      @sp.write("mode #{mode}\r")
    end
  end

  def close
    @sp.close
  end
end

led = IndicatorLed.new

# SerialPort.open("COM31", 9600) do |sp|

puts 'Setting mode to inactive'
led.setMode('i')
# sp.write("mode i\r")
sleep(1)
puts 'Setting mode to running'
led.setMode('r')
# sp.write("mode r\r")
sleep(15)
puts 'Setting mode to failed'
led.setMode('f')
# sp.write("mode f\r")
sleep(5)
puts 'Setting mode to running'
led.setMode('r')
# sp.write("mode r\r")
sleep(15)
puts 'Setting mode to succeeded'
led.setMode('s')
# sp.write("mode s\r")
sleep(5)

led.close