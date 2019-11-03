gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup
include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)

FFI::WiringPi::Pcf8591.setup 64, 0x48
FFI::WiringPi::GPIO.set_pin_mode 1, FFI::WiringPi::GPIO::INPUT

loop do
  value_x = analog_read(64)
  value_y = analog_read(65)
  value_z = read(1)

  print "\rADC: x #{value_x.to_i}, y: #{value_y.to_i}, z: #{value_z}"
  sleep 0.1
end
