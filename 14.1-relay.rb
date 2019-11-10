gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup
include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)

FFI::WiringPi::GPIO.set_pin_mode 0, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode 1, FFI::WiringPi::GPIO::INPUT

button = true
last = false
loop do
  value = read(1)
  if last && value != last
    button = !button
    write 0, button
  end
last = value
  print "\rButton: #{button}    "
  
  sleep 0.1
end
