
#define address 0x48 //pcf8591 default address
#define pinbase 64 //any number above 64
#define A0 pinbase + 0
#define A1 pinbase + 1
#define A2 pinbase + 2
#define A3 pinbase + 3
#define ledRedPin 3 //define 3 pins of RGBLED
#define ledGreenPin 2
#define ledBluePin 0
# int main(void){
#  int val_Red,val_Green,val_Blue;
#  if(wiringPiSetup() == -1){ //when initialize wiring failed, print message to screen
#  printf("setup wiringPi failed !");
#  return 1;
#  }
#  softPwmCreate(ledRedPin,0,100); //create 3 PWM output pins for RGBLED
#  softPwmCreate(ledGreenPin,0,100);
# softPwmCreate(ledBluePin,0,100);
#  pcf8591Setup(pinbase,address); //initialize PCF8591

#  while(1){
#  val_Red = analogRead(A0); //read 3 potentiometers
#  val_Green = analogRead(A1);
#  val_Blue = analogRead(A2);
#  softPwmWrite(ledRedPin,val_Red*100/255); //map the read value of
# potentiometers into PWM value and output it
#  softPwmWrite(ledGreenPin,val_Green*100/255);
#  softPwmWrite(ledBluePin,val_Blue*100/255);
#  //print out the read ADC value
#  printf("ADC value val_Red: %d ,\tval_Green: %d ,\tval_Blue: %d
# \n",val_Red,val_Green,val_Blue);
#  delay(100);
#  }
#  return 0;
# }


gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup
include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)
#FFI::WiringPi::GPIO.set_pin_mode 0, FFI::WiringPi::GPIO::OUTPUT
#FFI::WiringPi::GPIO.set_pin_mode 1, FFI::WiringPi::GPIO::INPUT

FFI::WiringPi::GPIO.setup

blue = FFI::WiringPi::SoftPwm::Pin.new 0
green = FFI::WiringPi::SoftPwm::Pin.new 2
red = FFI::WiringPi::SoftPwm::Pin.new 3

FFI::WiringPi::Pcf8591.setup 64, 0x48

loop do
  value_red = analog_read(64)
  value_green = analog_read(65)
  value_blue = analog_read(66)
  red.write(value_red * 100 / 256 +1)
  green.write(value_green * 100 / 256 + 1)
  blue.write(value_blue * 100 / 256 + 1)
  
  puts "ADC: #{value_red}, #{value_green}, #{value_blue}"
  sleep 0.01 
end
