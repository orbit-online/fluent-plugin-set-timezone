# Timezone setter for [Fluentd](https://www.fluentd.org/)

Shift the timezone of an event using the value of a field on that event.

## Installation

Use RubyGems:

gem install fluent-plugin-set-timezone

## Configuration

There is only one option: `timezone_key`

```
<filter pattern>
  @type set_timezone
  timezone_key timezone
</filter>
```

It supports the [record accessor syntax](https://docs.fluentd.org/plugin-helper-overview/api-plugin-helper-record_accessor#syntax)

A record like this:

```
["2016-11-03T15:58:09.138+03:00", {"msg":"hello!","timezone":"America/New_York"}]
```

will be transformed to:

```
["2016-11-03T15:58:09.138-05:00", {"msg":"hello!","timezone":"America/New_York"}]
```

Accepted formats are those parseable by [tzinfo](https://github.com/tzinfo/tzinfo) (i.e. the entire timezone DB),
but also offsets parseable by [`Time.zone_offset(timezone)`](https://docs.ruby-lang.org/en/2.5.0/Time.html#method-c-zone_offset) (meaning `+0100` or `-05:00`).

It is highly recommended to use timezone _names_ rather than offsets,
because the actual offset is calculated using the offset of the zone _at the given event time_.
This way daylight savings time (and the removal of it in e.g. the EU) is taken into account even in the hours around the change.

An invalid timezone raises an error. No timezone (`nil` or `''`) simply returns the existing time.
