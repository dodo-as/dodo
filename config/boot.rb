require 'rubygems'

require 'yaml'
YAML::ENGINE.yamler= 'syck'

# Set up gems listed in the Gemfile.
if File.exist?(File.expand_path('../../Gemfile', __FILE__))
  require 'bundler'
  Bundler.setup
end
