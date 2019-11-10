gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup
include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)

FFI::WiringPi::GPIO.set_pin_mode 1, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode 4, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode 5, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode 6, FFI::WiringPi::GPIO::OUTPUT
PINS = [1,4,5,6]
PHASE = [
	{ 1 => true, 4 => false, 5 => false, 6 => false },
	{ 1 => false, 4 => true, 5 => false, 6 => false },
	{ 1 => false, 4 => false, 5 => true, 6 => false },
	{ 1 => false, 4 => false, 5 => false, 6 => true }
]
loop do
  512.times do
  	4.times do |i|
	    PINS.each do |pin|
        write pin, PHASE[i][pin]
	    end
      sleep 0.003
	  end 
  end

  512.times do
  	4.times do |i|
	    PINS.each do |pin|
        write pin, PHASE[3 - i][pin]
	    end
      sleep 0.003
	  end 
  end
  sleep 2
end
