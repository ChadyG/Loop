class Temperature > EveryBit::Profile
	# Define properties that get pushed to Loop
	property :humidity
	property :temperature_faherenheit
	property :temperature_celcius
	property :temperature_kelvin
	property :dew_point
	property :dew_point_fast

	# Configure local API endpoints from our sensor devices
	def initialize(data)
	
	end
	
	# Define command callbacks
	def blink(index, enable)
	
	end
end