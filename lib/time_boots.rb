# encoding: utf-8
require 'time'

module TimeBoots
  # rubocop:disable Style/ModuleFunction
  extend self
  # rubocop:enable Style/ModuleFunction

  def steps
    Boot.steps
  end

  # NB: no fancy meta-programming here: we want YARD to be happy

  # Boot shortcuts

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

  # Boot-less method shortcuts
  # :nocov:
  def floor(step, tm)
    Boot.get(step).floor(tm)
  end

  def ceil(step, tm)
    Boot.get(step).ceil(tm)
  end

  def round(step, tm)
    Boot.get(step).round(tm)
  end

  def round?(step, tm)
    Boot.get(step).round?(tm)
  end

  def advance(step, tm, steps = 1)
    Boot.get(step).advance(step, tm, steps)
  end

  def decrease(step, tm, steps = 1)
    Boot.get(step).decrease(step, tm, steps)
  end

  def range(step, tm, steps = 1)
    Boot.get(step).range(tm, steps)
  end

  def range_back(step, tm, steps = 1)
    Boot.get(step).range_back(tm, steps)
  end

  def jump(step, steps = 1)
    Boot.get(step).jump(steps)
  end

  def measure(from, to, options = {})
    Measure.measure(from, to, options)
  end

  def lace(step, from, to, options = {})
    Boot.get(step).lace(from, to, options)
  end
  # :nocov:
end

require_relative './time_boots/boot'
require_relative './time_boots/lace'
require_relative './time_boots/measure'
require_relative './time_boots/jump'
