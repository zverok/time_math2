# Time Boots

**TimeBoots** is small, no-dependencies library attemting to make time
steps easier.

What it can?

```ruby
TimeBoots.steps

# => [:sec, :min, :hour, :day, :week, :month, :year]

tm = Time.parse('2015-03-05 10:08')
# => 2015-03-05 10:08:00

TimeBoots.floor(tm, :hour)
# => 2015-03-05 10:00:00

TimeBoots.floor(tm, :month)
# => 2015-03-01 00:00:00
# or
TimeBoots.month.floor(tm)
# => 2015-03-01 00:00:00

TimeBoots.month.ceil(tm)
# =>

TimeBoots.day.span(4)
# 
# it's like 4.days in Rails, but without Rails!

# Also, you can do
require 'time_boots/core_ext'
4.days

# Gotcha:
4.months
# => 
# Special class
# Which IS reasonable, as there's no such thing as "constant month length"
# No you can:

# But what if I want to advance by 4 monthes?
# Easy!
TimeBoots.month.advance(tm, 4)
# =>

# As well as  
TimeBoots.month.advance(tm, -4)
# =>
# or, if you wish
TimeBoots.month.decrease(tm, 4)
# =>

# Some gotchas:

TimeBoots.month.beginning?(Time.parse('2015-03-01'))
# true

# JFYI, all TimeBoots methods also can work with strings, but output
# will be Time nevertheless:

TimeBoots.month.floor('2015-03-05 20:45:11')
# => 2015-03-01 00:00:00
```

## Measuring time

```ruby
# My real birthday, in fact!
birthday = Time.parse('1983-14-02 13:30')

# How much days have I lived?
TimeBoots.day.measure(Time.now - birthday)
# =>

# My full age
TimeBoots.measure(Time.now - birthday)
# => {year: 32, month: 1, day: 5, hour: 13, minute: 5}

# My full age in days, hours, minutes
TimeBoots.measure(Time.now - birthday, max: :day)
# => {day: 5, hour: 13, min: 5}
```

See `examples/measure.rb` for those cases

## Laces

I'm a real fan of funny names in gems. So, we have time boots for working
with time steps. So, something continuous will be called **lace**.

```ruby
lace = TimeBoots.month.lace(from, to)
# => TimeBoots::Lace(blah - blah)

# or TimeBoots.lace(:month, from, to)

lace.pull

lace.pull(floor: true)

lace.expand
```

## Resampling
