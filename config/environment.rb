# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Slim::Application.initialize!
Time::DATE_FORMATS[:slim] = "%A %B %d, %Y"
