# encoding: utf-8
require 'time'

module TimeBoots
  extend self
  
  def steps
    Boot.steps
  end

  # no fancy meta-programming here: we want YARD to be happy

  def sec
    Boot.get(:sec)
  end

  def min
    Boot.get(:min)
  end

  def hour
    Boot.get(:hour)
  end

  def day
    Boot.get(:day)
  end

  def week
    Boot.get(:week)
  end

  def month
    Boot.get(:month)
  end

  def year
    Boot.get(:year)
  end
end

require_relative './time_boots/boot'
require_relative './time_boots/lace'
require_relative './time_boots/measure'
require_relative './time_boots/span'
