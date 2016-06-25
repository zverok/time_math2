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

* No monkey-patching of core classes (now **strict**; previously existing opt-in
  core ext removed in 0.0.5);
* Works with Time, Date and DateTime;
* Accurately preserves timezone info;
* Simple arithmetics: floor/ceil/round to any time unit (second, hour, year
  or whatnot), advance/decrease by any unit;
* Chainable operations, including construction of "set of operations"
  value object (like "10:20 at next month first day"), clean and powerful;
* Easy generation of time sequences (like "each day from _this_ to _that_
  date");
* Measuring of time distances between two timestamps in any units.

## Naming

`TimeMath` is the best name I know for the task library does, yet
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

**Things to note**:

* rounding methods (`floor`, `ceil` and company) support optional second
  argument—amount of units to round to, like "each 3 hours": `hour.floor(tm, 3)`;
* both rounding and advance/decrease methods allow their last argument to
  be float/rational, so you can `hour.advance(tm, 1/2r)` and this would
  work as you may expect. Non-integer arguments are only supported for
  units less than week (because "half of month" have no exact mathematical
  sense).

See also [Units::Base](http://www.rubydoc.info/gems/time_math2/TimeMath/Units/Base).

### Set of operations as a value object

For example, you want "10 am at next monday". By using atomic time unit
operations, you'll need the code like:

```ruby
TimeMath.hour.advance(TimeMath.week.ceil(Time.now), 10)
```
...which is not really readable, to say the least. So, `TimeMath` provides
one top-level method allowing to chain any operations you want:

```ruby
TimeMath(Time.now).ceil(:week).advance(:hour, 10).call
```

Much more readable, huh?

The best thing about it, that you can prepare "operations list" value
object, and then use it (or pass to methods, or
serialize to YAML and deserialize in some Sidekiq task and so on):

```ruby
op = TimeMath().ceil(:week).advance(:hour, 10)
# => #<TimeMath::Op ceil(:week).advance(:hour, 10)>
op.call(Time.now)
# => 2016-06-27 10:00:00 +0300

# It also can be called on several arguments/array of arguments:
op.call(tm1, tm2, tm3)
op.call(array_of_timestamps)
# ...or even used as a block-ish object:
array_of_timestamps.map(&op)
```

See also [TimeMath()](http://www.rubydoc.info/gems/time_math2/toplevel#TimeMath-instance_method)
and underlying [TimeMath::Op](http://www.rubydoc.info/gems/time_math2/TimeMath/Op)
class docs.

### Time sequence abstraction

Time sequence allows you to generate an array of time values between some
points:

```ruby
to = Time.now
# => 2016-05-28 17:47:30 +0300
from = TimeMath.day.floor(to)
# => 2016-05-28 00:00:00 +0300
seq = TimeMath.hour.sequence(from...to)
# => #<TimeMath::Sequence(:hour, 2016-05-28 00:00:00 +0300...2016-05-28 17:47:30 +0300)>
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

Note that sequence also play well with operation chain described above,
so you can

```ruby
seq = TimeMath.day.sequence(Time.parse('2016-05-01')...Time.parse('2016-05-04')).advance(:hour, 10).decrease(:min, 5)
# => #<TimeMath::Sequence(:day, 2016-05-01 00:00:00 +0300...2016-05-04 00:00:00 +0300).advance(:hour, 10).decrease(:min, 5)>
seq.to_a
# => [2016-05-01 09:55:00 +0300, 2016-05-02 09:55:00 +0300, 2016-05-03 09:55:00 +0300]
```

See also [Sequence YARD docs](http://www.rubydoc.info/gems/time_math2/TimeMath/Sequence).

### Measuring time periods

Simple measure: just "how many `<unit>`s from date A to date B":

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

### Notes on timezones

TimeMath tries its best to preserve timezones of original values. Currently,
it means:

* For `Time` instances, symbolic timezone is preserved; when jumping over
  DST border, UTC offset will change and everything remains as expected;
* For `DateTime` Ruby not provides symbolic timezone, only numeric offset;
  it is preserved by TimeMath (but be careful about jumping around DST,
  offset would not change).

## Compatibility notes

TimeMath is known to work on MRI Ruby >= 1.9.

On JRuby it works, too, though there could be _slightly_ unexpected results,
when JRuby fails to create time by timezone name (see [bug](https://github.com/jruby/jruby/issues/3978)).
TimeMath in this case fallbacks to the same solution that used for `DateTime`,
and at least preserves utc offset.

On Rubinius, some of tests fail and I haven't time to investigate it. If
somebody still uses Rubinius and wants TimeMath to be working properly
on it, please let me know.

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
