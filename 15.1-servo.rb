gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup
include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)

enable_pin = FFI::WiringPi::SoftPwm::Pin.new 1, 0, 200

loop do	
  (0..180).each do |angle|
    enable_pin.write(5 + (angle/180.0)*20)
    puts "\r Angle: #{angle}    "
    sleep 0.001
  end
  (0..180).each do |angle|
    enable_pin.write(5 + ((180-angle)/180.0)*20)
    puts "\r Angle: #{angle}    "
    sleep 0.001
  end

  sleep 0.1
end
