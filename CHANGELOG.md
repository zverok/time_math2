# TimeMath Changelog

# 0.0.6 (2016-12-14)

* Fix approach to timezone info preservation (previously, it was clear bug, emerging from
  false believing of how `Time.mktime` works). Thanks, @wojtha, for pointing to the problem.
* Add `#each` and `Enumerable` to `Sequence` (no idea why it wasn't done from the very
  beginning). Again: thanks, @wojtha!

# 0.0.5 (2016-06-25)

* Add support for `Date`;
* Add optional second argument to rounding functions (`floor`, `ceil` and
  so on), for "floor to 3-hour mark";
* Allow this argument, as well as in `advance`/`decrease`, to be non-integer;
  so, you can do `hour.advance(tm, 1/2r)` now;
* Drop any `core_ext`s completely, even despite it was optional;
* Add `Op` chainable operations concept (and drop `Span`, which
  is inferior to it);
* Redesign `Sequence` creation, allow include/exclude end;
* Add (experimental) resampling feature.

# 0.0.4 (2016-05-28)

* First "real" release with current name, `Time` and `DateTime` support,
  proper documentation and stuff.
