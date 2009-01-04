require 'rubygems'
require 'vendor/sinatra/lib/sinatra.rb'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production,
  :raise_errors => true,
  :app_file => 'githubemailclub.rb'    
)

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

require 'githubemailclub.rb'
run Sinatra.application
