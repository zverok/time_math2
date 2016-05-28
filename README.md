# Time Math

[![Gem Version](https://badge.fury.io/rb/time_math2.svg)](http://badge.fury.io/rb/time_math2)
[![Dependency Status](https://gemnasium.com/zverok/time_math2.svg)](https://gemnasium.com/zverok/time_math2)
[![Code Climate](https://codeclimate.com/github/zverok/time_math2/badges/gpa.svg)](https://codeclimate.com/github/zverok/time_math2)
[![Build Status](https://travis-ci.org/zverok/time_math2.svg?branch=master)](https://travis-ci.org/zverok/time_math2)
[![Coverage Status](https://coveralls.io/repos/zverok/time_math2/badge.svg?branch=master)](https://coveralls.io/r/zverok/time_math2?branch=master)

**TimeMath2** is a small, no-dependencies library attempting to make time
arithmetics easier. It provides you with simple, easy-to-remember API, without
any monkey-patching of core Ruby classes, so it can be used alongside
Rails or without it, for any purpose.

## Features

* No monkey-patching of core classes (opt-in patching of Time and DateTime
  provided, though);
* Works with Time and DateTime;
* Accurately preserves timezone info;
* Simple arithmetics: floor/ceil/round to any time unit (second, hour, year
  or whatnot), advance/decrease by any unit;
* Simple time span abstraction (like "5 years" object you can store and
  pass to other methods);
* Easy generation of time sequences (like "each day from _this_ to _that_
  date");
* Measuring of time distances between two timestamps in any units.

## Naming

`TimeMath` is the better name I know for the task library does, but
it is [already taken](https://rubygems.org/gems/time_math). So, with no
other thoughts I came with the ugly solution.

(BTW, the [previous version](https://github.com/zverok/time_math/blob/e997d7ddd52fc5bce3c77dc3c8022adfc9fe7028/README.md)
had some dumb "funny" name for gem and all helper classes, and nobody liked it.)

## Reasons

You frequently need to calculate things like "exact midnight of the next
day", but you don't want to monkey-patch all of your integers, tug in
5K LOC of ActiveSupport and you like to have things clean and readable.

## Installation

Install it like always:

```
$ gem install time_math2
```

or add to your Gemfile

```ruby
gem 'time_math2'
```

and `bundle install` it.

## Usage

First, you take time unit you want:

```ruby
TimeMath[:day] # => #<TimeMath::Units::Day>
# or
TimeMath.day # => #<TimeMath::Units::Day>

# List of units supported:
TimeMath.units
# => [:sec, :min, :hour, :day, :week, :month, :year]
```

Then you use this unit for any math you want:

```ruby
TimeMath.day.floor(Time.now) # => 2016-05-28 00:00:00 +0300
TimeMath.day.ceil(Time.now) # => 2016-05-29 00:00:00 +0300
TimeMath.day.advance(Time.now, +10) # => 2016-06-07 14:06:57 +0300
# ...and so on
```

### Full list of simple arithmetic methods

* `<unit>.floor(tm)` -- rounds down to nearest `<unit>`;
* `<unit>.ceil(tm)` -- rounds up to nearest `<unit>`;
* `<unit>.round(tm)` -- rounds to nearest `<unit>` (up or down);
* `<unit>.round?(tm)` -- checks if `tm` is already round to `<unit>`;
* `<unit>.prev(tm)` -- like `floor`, but always decreases:
    - `2015-06-27 13:30` would be converted to `2015-06-27 00:00` by both
      `floor` and `prev`, but
    - `2015-06-27 00:00` would be left intact on `floor`, but would be
      decreased to `2015-06-26 00:00` by `prev`;
* `<unit>.next(tm)` -- like `ceil`, but always increases;
* `<unit>.advance(tm, amount)` -- increases tm by integer amount of `<unit>`s;
* `<unit>.decrease(tm, amount)` -- decreases tm by integer amount of `<unit>`s;
* `<unit>.range(tm, amount)` -- creates range of `tm ... tm + amount <units>`;
* `<unit>.range_back(tm, amount)` -- creates range of `tm - amount <units> ... tm`.

See also [Units::Base](http://www.rubydoc.info/gems/time_math2/TimeMath/Units/Base).

### Time span abstraction

`TimeMath::Span` is a simple abstraction of "N units of time", which you
can store in variable and then apply to some time value:

```ruby
span = TimeMath.day.span(5)
# => #<TimeMath::Span(day): +5>
span.before(Time.now)
# => 2016-05-23 17:46:13 +0300
```

See also [Span YARD docs](http://www.rubydoc.info/gems/time_math2/TimeMath/Span).

### Time sequence abstraction

Time sequence allows you to generate an array of time values between some
points:

```ruby
to = Time.now
# => 2016-05-28 17:47:30 +0300
from = TimeMath.day.floor(to)
# => 2016-05-28 00:00:00 +0300
seq = TimeMath.hour.sequence(from, to)
# => #<TimeMath::Sequence(2016-05-28 00:00:00 +0300 - 2016-05-28 17:47:30 +0300)>
p(*seq)
# 2016-05-28 00:00:00 +0300
# 2016-05-28 01:00:00 +0300
# 2016-05-28 02:00:00 +0300
# 2016-05-28 03:00:00 +0300
# 2016-05-28 04:00:00 +0300
# 2016-05-28 05:00:00 +0300
# 2016-05-28 06:00:00 +0300
# 2016-05-28 07:00:00 +0300
# ...and so on
```

See also [Sequence YARD docs](http://www.rubydoc.info/gems/time_math2/TimeMath/Sequence).

### Measuring time periods

Simple measure: just "how many `<unit>`s from date A to date B:

```ruby
TimeMath.week.measure(Time.parse('2016-05-01'), Time.parse('2016-06-01'))
# => 4
```

Measure with remaineder: returns number of `<unit>`s between dates and
the date when this number would be exact:

```ruby
TimeMath.week.measure_rem(Time.parse('2016-05-01'), Time.parse('2016-06-01'))
# => [4, 2016-05-29 00:00:00 +0300]
```

(on May 29 there would be exactly 4 weeks since May 1).

Multi-unit measuring:

```ruby
# My real birthday, in fact!
birthday = Time.parse('1983-02-14 13:30')

# My full age
TimeMath.measure(birthday, Time.now)
# => {:years=>33, :months=>3, :weeks=>2, :days=>0, :hours=>1, :minutes=>25, :seconds=>52}

# NB: you can use this output with String#format or String%:
puts "%{years}y %{months}m %{weeks}w %{days}d %{hours}h %{minutes}m %{seconds}s" %
  TimeMath.measure(birthday, Time.now)
# 33y 3m 2w 0d 1h 26m 15s

# Option: measure without weeks
TimeMath.measure(birthday, Time.now, weeks: false)
# => {:years=>33, :months=>3, :days=>14, :hours=>1, :minutes=>26, :seconds=>31}

# My full age in days, hours, minutes
TimeMath.measure(birthday, Time.now, upto: :day)
# => {:days=>12157, :hours=>2, :minutes=>26, :seconds=>55}
```

### Optional `Time` and `DateTime` patches

This core classes extension is optional and should be required explicitly.
TimeMath doesn't change behavior of any existing methods (like `#+`),
it just adds a couple of new ones:

```ruby
require 'time_math/core_ext'

Time.now.decrease_by(:day, 10).floor_to(:month)
Time.now.sequence_to(:month, Time.now.advance_by(:year, 5))
```

See [CoreExt](http://www.rubydoc.info/gems/time_math2/TimeMath/CoreExt)
documentation for full lists of methods added.

### Notes on timezones

TimeMath tries its best to preserve timezones of original values. Currently,
it means:

* For `Time` instances, symbolic timezone is preserved; when jumping over
  DST border, UTC offset will change and everything remains as expected;
* For `DateTime` Ruby not provides symbolic timezone, only numeric offset;
  it is preserved by TimeMath (but be careful about jumping around DST,
  offset would not change).


## Time series generation: "laces"

I'm a real fan of funny names in gems. Here we have time **boots** for working
with time **steps**. So, something continuous will be called **lace**.

I hope, next examples are pretty self-explanatory.

```ruby
from = Time.parse('2015-03-05 10:08')
to = Time.parse('2015-03-09 11:07')

lace = TimeBoots.month.lace(from, to)
# => #<TimeBoots::Lace(2015-03-05 10:08:00 +0200 - 2015-03-09 11:07:00 +0200)>

# or
TimeBoots.lace(:month, from, to)
# => #<TimeBoots::Lace(2015-03-05 10:08:00 +0200 - 2015-03-09 11:07:00 +0200)>

lace.pull
# => [2015-03-05 10:08:00 +0200,
#     2015-03-06 10:08:00 +0200,
#     2015-03-07 10:08:00 +0200,
#     2015-03-08 10:08:00 +0200,
#     2015-03-09 10:08:00 +0200]
```

So, we have just a series of times, each day, from `from` until `to`.
Note, there is a same time of the day (10:08), as it was in `from`.

The `pull` method has an optional argument, when it is `true`, the
method returns `floor`-ed times (e.g. midnights for daily lace):

```ruby
lace.pull(true)
# => [2015-03-05 10:08:00 +0200,
#     2015-03-06 00:00:00 +0200,
#     2015-03-07 00:00:00 +0200,
#     2015-03-08 00:00:00 +0200,
#     2015-03-09 00:00:00 +0200]
```

Note the first value still at 10:08: we don't want to go before `from`.
Lace also can "expand" your period for you (`floor` the beginning and
`ceil` the end):

```ruby
lace.expand
# => #<TimeBoots::Lace(2015-03-05 00:00:00 +0200-2015-03-10 00:00:00 +0200)>

# or
lace.expand!

# or start with expanded:
TimeBoots.month.lace(from, to, expanded: true)
```

Another useful lace's functionality is generating periods.
It can be useful for filtering daily data from database, for example:

```ruby
lace.pull_ranges
# => [2015-03-05 10:08:00 +0200...2015-03-06 10:08:00 +0200,
#     2015-03-06 10:08:00 +0200...2015-03-07 10:08:00 +0200,
#     2015-03-07 10:08:00 +0200...2015-03-08 10:08:00 +0200,
#     2015-03-08 10:08:00 +0200...2015-03-09 10:08:00 +0200,
#     2015-03-09 10:08:00 +0200...2015-03-09 11:07:00 +0200]

# Now, you can do something like:

lace.pull_ranges.map{|range| dataset.where(timestamp: range).count}
# ...and have your daily stats with one line of code

```

## Got it, what else?

TimeMath also play well when included into other classes or modules:

```ruby
class MyModel
  include TimeMath

  def next_day
    day.advance # Here!
  end
end
```

## Alternatives

There's pretty small and useful [AS::Duration](https://github.com/janko-m/as-duration)
by Janko Marohnić, which is time durations, extracted from ActiveSupport,
but without any ActiveSupport bloat.

## Links

* [API Docs](http://www.rubydoc.info/gems/time_math2)

## Author

[Victor Shepelev](http://zverok.github.io/)

## License

[MIT](https://github.com/zverok/time_math2/blob/master/LICENSE.txt).
