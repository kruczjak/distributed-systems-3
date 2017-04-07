require 'bundler/setup'
require 'active_support/all'
require 'require_all'

Bundler.require

require_all 'lib'
require_relative 'doctor'
require_relative 'technician'

p "Starting #{ARGV}"

class_name = ARGV[0].to_s
ARGV.shift

class_name.to_s.constantize.new(ARGV).loop_program
