
gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup

include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)



class Keypad
  attr_reader :data
  
  def initialize(rows, columns)
    @rows = rows
    @columns = columns
    @data = {}
  end
  
  def fetch
    
    @rows.each do |pin|
      FFI::WiringPi::GPIO.set_pin_mode pin, FFI::WiringPi::GPIO::INPUT
    end
    @columns.each do |pin|
      FFI::WiringPi::GPIO.set_pin_mode pin, FFI::WiringPi::GPIO::OUTPUT
    end
    @columns.each_with_index do |column, index|
      FFI::WiringPi::GPIO.write column, true
      @rows.each_with_index do |row, index_row|
        @data[index] ||= {}
        @data[index][index_row] = FFI::WiringPi::GPIO.read row
      end
      FFI::WiringPi::GPIO.write column, false
    end
  end

  
end  

sensor = Keypad.new [1,4,5,6], [12, 3, 2, 0]

loop do
  sensor.fetch
  pp sensor.data
  sleep 2
end
