# encoding: utf-8
require 'time'

module TimeBoots
  module_function
  
  def steps
    Boot.steps
  end
end

require_relative './time_boots/boot'
require_relative './time_boots/lace'
require_relative './time_boots/measure'
require_relative './time_boots/span'
