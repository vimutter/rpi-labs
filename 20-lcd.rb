
gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup

include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)

# Used by LCD internally
#define_method :digitalWrite, &FFI::WiringPi::GPIO.method(:write)
#FFI::WiringPi::LCD.setup

#define pcf8574_address 0x27 // default I2C address of Pcf8574
ADDRESS = 0x27#0x3F # default I2C address of Pcf8574A
BASE = 64 # BASE is not less than 64
# Define the output pins of the PCF8574, which are directly connected to the
# LCD1602 pin.
RS = BASE+0
RW = BASE+1
EN = BASE+2
LED = BASE+3
D4 = BASE+4
D5 = BASE+5
D6 = BASE+6
D7 = BASE+7

def print_cpu_temperature(display)
 
 # CPU temperature data is stored in this directory.
 fp = File.read("/sys/class/thermal/thermal_zone0/temp")
 temp = fp.to_f / 1000.0
 puts "CPU's temperature : #{temp.ceil(2)}"
 display.set_position(0, 0)
 display.puts(format("CPU:%.2fC",temp)) #Display CPU temperature on LCD
end

def print_date(display) 
 display.set_position(0, 1)
 time = Time.now
 display.puts(format("Time:%d:%d:%d",time.hour, time.min, time.sec))
end
 
 FFI::WiringPi::Pcf8574.setup BASE, ADDRESS
 
8.times do |i|
  FFI::WiringPi::GPIO.set_pin_mode(BASE + i, FFI::WiringPi::GPIO::OUTPUT)
end
 
write LED, true # turn on LCD backlight
write RW, false # allow writing to LCD
# initialize LCD and return display instance
display = FFI::WiringPi::LCD::Display.new rows: 2, 
  cols: 16, bits: 4, rs: RS, strb: EN, d0: D4, d1: D5, d2: D6, d3: D7, 
  d4: 0, d5: 0, d6: 0, d7: 0 

pp display.instance_variable_get(:@handle)
display.turn_display true
loop do
  print_cpu_temperature display
  print_date display
  sleep 1 
end
 
