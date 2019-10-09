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


loop do 
	sleep 0.1
	unless read 1
		p read(1)
		write 0, true
	else write 0, false
	end
end
