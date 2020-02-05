#include <wiringPi.h>
#include <stdio.h>
#include <wiringShift.h>
#define dataPin 0 //DS Pin of 74HC595(Pin14)
#define latchPin 2 //ST_CP Pin of 74HC595(Pin12)
#define clockPin 3 //SH_CP Pin of 74HC595(Pin11)

gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup
include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)

# enable_pin = FFI::WiringPi::SoftPwm::Pin.new 1, 0, 200
data_pin = 0
latch_pin = 2
clock_pin = 3

FFI::WiringPi::GPIO.set_pin_mode data_pin, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode latch_pin, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode clock_pin, FFI::WiringPi::GPIO::OUTPUT


def shiftOut(dPin,cPin,val)
 8.times do |i|
 	write cPin, false
 	write dPin, ((0x01&(val>>i)) == 0x01)
  sleep 0.00001
  write cPin, true
  sleep 0.00001
 end
end

loop do
  x = 0x01
  8.times do
    write latch_pin, false
    shiftOut data_pin, clock_pin, x
    write latch_pin, true
    x <<= 1
    sleep 0.1
  end

  x = 0x80
  8.times do
    write latch_pin, false
    shiftOut data_pin, clock_pin, x
    write latch_pin, true
    x >>= 1
    sleep 0.1
  end  
end