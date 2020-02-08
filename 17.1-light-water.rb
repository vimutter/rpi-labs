
gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup
include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)

data_pin = 0
latch_pin = 2
clock_pin = 3

FFI::WiringPi::GPIO.set_pin_mode data_pin, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode latch_pin, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode clock_pin, FFI::WiringPi::GPIO::OUTPUT

def shift_out(data_pin, clock_pin, val)
  8.times do |i|
   	write clock_pin, false
 	  write data_pin, (val>>i == 1)
    sleep 0.00001
    write clock_pin, true
    sleep 0.00001
  end
end

loop do
  x = 0x01
  8.times do
    write latch_pin, false
    shift_out data_pin, clock_pin, x
    write latch_pin, true
    x <<= 1
    sleep 0.01
  end

  x = 0x80
  8.times do
    write latch_pin, false
    shift_out data_pin, clock_pin, x
    write latch_pin, true
    x >>= 1
    sleep 0.01
  end  
end
