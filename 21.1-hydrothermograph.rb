
gem 'ffi-wiring_pi'

require 'ffi/wiring_pi'

FFI::WiringPi::GPIO.setup

include FFI::WiringPi::GPIO
extend FFI::WiringPi::GPIO
define_method :get, &FFI::WiringPi::GPIO.method(:get)
define_method :write, &FFI::WiringPi::GPIO.method(:write)
define_method :read, &FFI::WiringPi::GPIO.method(:read)
define_method :analog_read, &FFI::WiringPi::GPIO.method(:analog_read)



class DHT
  attr_reader :temperature, :humidity
  DHTLIB_OK = 0
  DHTLIB_ERROR_CHECKSUM = -1
  DHTLIB_ERROR_TIMEOUT = -2
  DHTLIB_INVALID_VALUE = -999
  
  DHTLIB_DHT11_WAKEUP = 0.020#0.018       #18ms
  DHTLIB_TIMEOUT = 0.0001         #100us
  
  humidity = 0
  temperature = 0

  def initialize(pin)
    @pin = pin
    @bits = [0, 0, 0, 0, 0]
  end
  
  def fetch(wakeup_delay = 1)
    mask = 0x80
    idx = 0
    data = Array.new(1000)
    FFI::WiringPi::GPIO.set_pin_mode @pin, FFI::WiringPi::GPIO::OUTPUT
    FFI::WiringPi::GPIO.write @pin, false
    
    sleep 0.018
    FFI::WiringPi::GPIO.write @pin, true
    sleep 0.00004
    FFI::WiringPi::GPIO.set_pin_mode @pin, FFI::WiringPi::GPIO::INPUT

    1000.times do |i|
      data[i] = FFI::WiringPi::GPIO.read @pin
      sleep 0.00002 
    end
    p data
    exit 0
    

    wait_low_high
    
    5.times do |bit|
      mask = 0x80
      8.times do |shift|
        start = wait_low_high
        if (Time.now - start) > 0.00005
          @bits[bit] |= mask
        end        
          
        mask >>= 1
      end
    end
    FFI::WiringPi::GPIO.set_pin_mode @pin, FFI::WiringPi::GPIO::OUTPUT
    FFI::WiringPi::GPIO.write @pin, true
    
    DHTLIB_OK
  end

  def wait_low_high
    timeout = DHTLIB_TIMEOUT
    start = Time.now
    until FFI::WiringPi::GPIO.read(@pin)
      if (Time.now - start) > timeout
        return DHTLIB_ERROR_TIMEOUT
      end
    end

    start = Time.now
    while FFI::WiringPi::GPIO.read(@pin)
       if (Time.now - start) > timeout
        return DHTLIB_ERROR_TIMEOUT
      end
    end
    start
  end

  #Read DHT sensor, analyze the data of temperature and humidity
  def read
    status = fetch DHTLIB_DHT11_WAKEUP
    unless status == DHTLIB_OK
      @humidity = DHTLIB_INVALID_VALUE
      @temperature = DHTLIB_INVALID_VALUE
      return status
    end
    @humidity = @bits[0]
    @temperature = @bits[2] + @bits[3] * 0.1
    checksum = ((@bits[0] + @bits[1] + @bits[2] + @bits[3]) & 0xFF)
    unless @bits[4] == checksum
      return DHTLIB_ERROR_CHECKSUM
    end
    DHTLIB_OK
  end
end  

sensor = DHT.new 0 # PIN

loop do
  sensor.read
  puts "T: #{sensor.temperature}, h: #{sensor.humidity}"
  sleep 3
end