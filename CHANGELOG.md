# TimeMath Changelog

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
