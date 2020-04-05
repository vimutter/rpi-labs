
gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup

include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)

require 'bigdecimal'

TRIGGER = 4
DATA = 5

MAX_DISTANCE = 220#        // define the maximum measured distance
TIMEOUT = MAX_DISTANCE * 60 #// calculate timeout according to the maximum measured distance

def pulse_in(pin)
  start = Time.now
  until read(pin)
    sleep 0.000001
  end
  time = Time.now
  while read(pin)
    sleep 0.000001
  end  
  Time.now - time
end

def get_sonar   #get the measurement result of ultrasonic module with unit: cm
  write TRIGGER, true
  sleep 0.00001 
  write TRIGGER, false
  pingTime = BigDecimal(pulse_in(DATA))
  pingTime * 340.0 / 2.0 / 10000.0
end

FFI::WiringPi::GPIO.set_pin_mode TRIGGER, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode DATA, FFI::WiringPi::GPIO::INPUT

loop do
  p get_sonar.to_s('F')
  sleep 0.5 
end


