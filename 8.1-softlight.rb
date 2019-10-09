gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup
include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)
#FFI::WiringPi::GPIO.set_pin_mode 0, FFI::WiringPi::GPIO::OUTPUT
#FFI::WiringPi::GPIO.set_pin_mode 1, FFI::WiringPi::GPIO::INPUT

FFI::WiringPi::GPIO.setup

led = FFI::WiringPi::SoftPwm::Pin.new 0



FFI::WiringPi::Pcf8591.setup 64, 0x48

loop do
  value = analog_read(64)
  led.write(value * 100 / 256)
  volt = (value/256.0) * 3.3
  #puts "ADC: #{value}, volts: #{volt}"
  sleep 0.01
end
