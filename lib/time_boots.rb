# encoding: utf-8
require 'time'

module TimeBoots
  module_function
  
  def steps
    Boot.steps
  end
end

require_relative './time_boots/boot'
