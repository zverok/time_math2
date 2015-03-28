# encoding: utf-8
require 'time'

module TimeBoots
  STEPS = [:sec, :min, :hour, :day, :week, :month, :year]

  module_function
  
  def steps
    STEPS
  end
end

require_relative './time_boots/boot'

__END__

  class << self
    def steps; STEPS end
    
    def floor(tm, step)
      new(step).floor(tm)
    end

    STEPS.each do |step|
      define_method(step) do
        new(step)
      end
    end
  end

  def initialize(step)
    @step = step
  end

  attr_reader :step


  def ceil(tm)
    fl = floor(tm)
    return fl if fl == tm
    
    case step
    when :min
    when :hour
      # FIXME: wtf???
      Time.new(fl.year, fl.month, fl.day, fl.hour+1, 0, 0)
    when :day
      if fl.day == days_in_month(fl.month, fl.year)
          Time.new(fl.year, fl.month+1, 1, 0, 0, 0)
      else
          Time.new(fl.year, fl.month, fl.day+1, 0, 0, 0)
      end
    when :week
      TimeBoots.day.ceil(fl+TimeBoots.day.span(7))
    when :month
      if fl.month == 12
        Time.new(fl.year+1, 1, 1, 0, 0, 0)
      else
        Time.new(fl.year, fl.month+1, 1, 0, 0, 0)
      end
    end  
  end
end
