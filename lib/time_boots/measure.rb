# encoding: utf-8
module TimeBoots
  module Measure
    PLURALS = {
      year: :years,
      month: :months,
      week: :weeks,
      day: :days,
      hour: :hours,
      min: :minutes,
      sec: :seconds
    }.freeze

    def self.measure(from, to, options = {})
      select_steps(options).reverse.inject({}) do |res, step|
        span, from = Boot.get(step).measure_rem(from, to)
        res.merge(PLURALS[step] => span)
      end
    end

    def self.select_steps(options)
      steps = Boot.steps
      steps.delete(:week) if options[:weeks] == false

      if (idx = steps.index(options[:max_step]))
        steps = steps.first(idx + 1)
      end

      steps
    end
  end
end
