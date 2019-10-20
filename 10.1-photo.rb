gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup
include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)

blue = FFI::WiringPi::SoftPwm::Pin.new 0

FFI::WiringPi::Pcf8591.setup 64, 0x48

loop do
  value_blue = analog_read(64)

  blue.write(value_blue * 100 / 256)
  
  puts "ADC: #{value_blue}"
  sleep 0.01
end
