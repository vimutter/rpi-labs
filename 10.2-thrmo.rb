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

loop do
  value_blue = analog_read(64)

  voltage = value_blue / 255.0 * 3.3; # calculate voltage
  rt = 10 * voltage / (3.3 - voltage); #calculate resistance value of thermistor
  tempK = 1/(1/(273.15 + 25) + Math.log(rt/10)/3950.0); #calculate temperature (Kelvin)
  tempC = tempK - 273.15; #calculate temperature (Celsius)

  print "\rADC: #{value_blue.to_i}, volt: #{voltage.ceil(2)}, rt: #{rt}, tempK: #{tempK}, tempC: #{tempC}"
  sleep 0.1
end
