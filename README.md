# Time Boots

**TimeBoots** is small, no-dependencies library attemting to make time
steps easier. It provides you with simple, easy remembered API, without
any monkey patching of core Ruby classes, so it can be used alongside
Rails or without it, for any purpose.

What it can?

## Simple time math

### Floor, ceil and round:

```ruby
TimeBoots.steps

# => [:sec, :min, :hour, :day, :week, :month, :year]

tm = Time.parse('2015-03-05 10:08')
# => 2015-03-05 10:08:00 +0200

TimeBoots.floor(:hour, tm)
# => 2015-03-05 10:00:00 +0200

TimeBoots.floor(:month, tm)
# => 2015-03-01 00:00:00 +0200

# or
TimeBoots.month.floor(tm)
# => 2015-03-01 00:00:00 +0200

TimeBoots.month.ceil(tm)
# => 2015-04-01 00:00:00 +0300
# Note the timezone change: our (Ukraine) DST was in March,
# and TimeBoots plays perfectly well with it.

TimeBoots.month.round(tm)
# => 2015-03-01 00:00:00 +0200

TimeBoots.month.round?(tm)
# => false

TimeBoots.min.round?(tm)
# => true
```

### Moving in time forwards and backwards:

```ruby
TimeBoots.month.advance(tm)
# => 2015-04-05 10:08:00 +0300

TimeBoots.month.advance(tm, 4)
# => 2015-07-05 10:08:00 +0300

TimeBoots.month.advance(tm, -4)
# => 2014-11-05 10:08:00 +0200

# or
TimeBoots.month.decrease(tm, 4)
# => 2014-11-05 10:08:00 +0200

# Or you can use an abstraction:
span = TimeBoots.month.span(4)
# => #<TimeBoots::Span: 4 month>

span.before(tm)
# => 2014-11-05 10:08:00 +0200
# also span.ago(tm)

span.after(tm)
# => 2015-07-05 10:08:00 +0300
# also span.from(tm)
```

Creating time ranges:

```ruby
TimeBoots.hour.range(tm, 5)
 => 2015-03-05 10:08:00 +0200...2015-03-05 15:08:00 +0200 
TimeBoots.hour.range_back(tm, 5)
 => 2015-03-05 05:08:00 +0200...2015-03-05 10:08:00 +0200 
```

## Measuring time periods

```ruby
# My real birthday, in fact!
birthday = Time.parse('1983-02-14 13:30')

# How many days have I lived?
TimeBoots.day.measure(birthday, Time.now)
# => 11764

# And how many weeks (with reminder)?
TimeBoots.week.measure_rem(birthday, Time.now)
# => [1680, 2015-04-27 12:30:00 +0300]
# the thing is "birthday plus 1680 weeks == reminder"

# My full age
TimeBoots.measure(birthday, Time.now)
# => {:years=>32, :months=>2, :weeks=>2, :days=>3, :hours=>6, :minutes=>59, :seconds=>7}

# NB: you can use this output with String#format or String%:
puts "%{years}y %{months}m %{weeks}w %{days}d %{hours}h %{minutes}m %{seconds}s" % TimeBoots.measure(birthday, Time.now)
# "32y 2m 2w 3d 7h 2m 50s"

# Option: measure without weeks
TimeBoots.measure(birthday, Time.now, weeks: false)
# => {:years=>32, :months=>2, :days=>17, :hours=>7, :minutes=>5, :seconds=>11} 

# My full age in days, hours, minutes
TimeBoots.measure(birthday, Time.now, max_step: :day)
# => {:days=>11764, :hours=>8, :minutes=>6, :seconds=>41}
```

See TimeBoots#measure for details.

## Time series generation: laces

I'm a real fan of funny names in gems. So, we have time **boots** for working
with time **steps**. So, something continuous will be called **lace**.

I hope, those examples are pretty self-explanatory.

```ruby
from = Time.parse('2015-03-05 10:08')
to = Time.parse('2015-03-09 11:07')

lace = TimeBoots.month.lace(from, to)
# => #<TimeBoots::Lace(2015-03-05 10:08:00 +0200-2015-03-09 11:07:00 +0200)>

# or
TimeBoots.lace(:month, from, to)
# => #<TimeBoots::Lace(2015-03-05 10:08:00 +0200-2015-03-09 11:07:00 +0200)>

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

TimeBoots also play well when included into other classes or modules:

```ruby
class MyModel
  include TimeBoots

  def next_day
    day.advance # Here!
  end
end
```

And there are some plans for the future:
* `TimeBoots.resample`, which would do resampling (take daily data and
  group it monthly, and so on) easy task;
* optional `core_ext`, providing methods like `4.months.ago` for the
  (Rails-less) rest of us;
* your ideas?..
