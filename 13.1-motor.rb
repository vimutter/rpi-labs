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

FFI::WiringPi::GPIO.set_pin_mode 3, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode 2, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode 0, FFI::WiringPi::GPIO::OUTPUT

enable_pin = FFI::WiringPi::SoftPwm::Pin.new
loop do
  value = analog_read(64)
  print "\rADC: #{value.to_i}"

  if value>128 
    write 2, true
    write 0, false
    puts("turn Forward...")
  elsif value<128 
    write 2, false
    write 0, true
    puts("turn Back...")
  else 
    write 2, false
    write 0, false
    puts("Motor Stop...")
  end	
  enable_pin.write (Math.abs(value - 128)/128.0) * 100
  puts "The PWM duty cycle is #{Math.abs(value - 128)/128.0}"

  sleep 0.1
end
