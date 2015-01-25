# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/application',  __FILE__)
run EveryBit::Application.new
