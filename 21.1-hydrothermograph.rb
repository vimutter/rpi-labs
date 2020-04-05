
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
    data = Array.new(600)
    FFI::WiringPi::GPIO.set_pin_mode @pin, FFI::WiringPi::GPIO::OUTPUT
    FFI::WiringPi::GPIO.write @pin, false
    
    sleep 0.018
    FFI::WiringPi::GPIO.write @pin, true
    #sleep 0.0000004
    FFI::WiringPi::GPIO.set_pin_mode @pin, FFI::WiringPi::GPIO::INPUT

    600.times do |i|
      data[i] = FFI::WiringPi::GPIO.read @pin
      sleep 0.0000009 
    end
    bits = []
    length = 0
    data.each do |el|
	    print(el ? :+ : :-)
      unless el # Start of the bit
        if length > 0 # End of bit, now lets find it's value
          if length > 5 # Usually 3, but depends on busyness of the system, we are in OS, remember
            bits << 1
          else
            bits << 0
          end 
        end
        length = 0
      end

      if el # actual data, longer it is more `1` it is
        length += 1
      end
    end

    @bits[0] = bits[0..7].join.to_i(2)
    @bits[1] = bits[8..15].join.to_i(2)
    @bits[2] = bits[16..23].join.to_i(2)
    @bits[3] = bits[24..31].join.to_i(2)
    @bits[4] = bits[32..39].join.to_i(2)
    
    # FFI::WiringPi::GPIO.set_pin_mode @pin, FFI::WiringPi::GPIO::OUTPUT
    # FFI::WiringPi::GPIO.write @pin, true
    
    DHTLIB_OK
  end

  #Read DHT sensor, analyze the data of temperature and humidity
  def read
    status = fetch DHTLIB_DHT11_WAKEUP
    unless status == DHTLIB_OK
      @humidity = DHTLIB_INVALID_VALUE
      @temperature = DHTLIB_INVALID_VALUE
      return status
    end
    @humidity = @bits[0] + @bits[1] * 0.1
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
