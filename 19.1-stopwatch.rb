
gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup
include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)

$data_pin = 5
$latch_pin = 4
$clock_pin = 1
$display_pins = [0, 2, 3, 12]

FFI::WiringPi::GPIO.set_pin_mode $data_pin, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode $latch_pin, FFI::WiringPi::GPIO::OUTPUT
FFI::WiringPi::GPIO.set_pin_mode $clock_pin, FFI::WiringPi::GPIO::OUTPUT
$display_pins.each do |i|
  FFI::WiringPi::GPIO.set_pin_mode i, FFI::WiringPi::GPIO::OUTPUT
end

NUMBERS = [0xc0,0xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90]
$counter = 0

def select_digit(digit)
  write $display_pins[0], (digit != 4)
  write $display_pins[1], (digit != 3)
  write $display_pins[2], (digit != 2)
  write $display_pins[3], (digit != 1)
end

def shift_out(data_pin, clock_pin, val)
  8.times do |i|
    j = 7 - i
   	write clock_pin, false
	  write data_pin, (val[j..j] == 1)#((val>>i) % 2 == 1)
    sleep 0.0001
    write clock_pin, true
    sleep 0.0001
  end
end

def push_data(data)
  write $latch_pin, false
  shift_out $data_pin, $clock_pin, data
  write $latch_pin, true
end

def display(number)
  delays = 0.00001
  push_data 0xff
  select_digit 1
  push_data(NUMBERS[number % 10])
  sleep delays

  push_data 0xff
  select_digit 2
  push_data(NUMBERS[(number % 100) / 10])
  sleep delays

  push_data 0xff
  select_digit 3
  push_data(NUMBERS[(number % 1000) / 100])
  sleep delays

  push_data 0xff
  select_digit 4
  push_data(NUMBERS[(number % 10000) / 1000])
  sleep delays
end

def timer(sig)
  $counter += 1
  puts $counter
end

4.times do |i|
  write $display_pins[i], true 
end

Thread.new do

  loop do 
    timer true
    sleep 1
  end
end

print "\a"
loop do
  display $counter
  sleep 0.00001
end

