require 'time'
require 'tzinfo'
require 'fluent/plugin/filter'
require 'fluent/plugin_helper'

module Fluent::Plugin
  class SetTimezoneFilter < Filter
    Fluent::Plugin.register_filter('set_timezone', self)
    helpers :record_accessor

    config_param :timezone_key, :string, :desc => 'The name of the key containing the timezone'

    def configure(conf)
      super
      if !@timezone_key
        raise Fluent::ConfigError, "timezone_key is required"
      end
      @accessor = record_accessor_create(@timezone_key)
    end

    def filter_with_time(tag, event_time, record)
      timezone = @accessor.call(record)
      return event_time, record unless timezone and !timezone.empty?
      time = event_time.to_time.utc
      begin
        tz = TZInfo::Timezone.get(timezone)
        adjusted = tz.local_time(time.year, time.month, time.day, time.hour, time.min, time.sec, Rational(time.nsec, 1000000000))
      rescue TZInfo::InvalidTimezoneIdentifier
        offset = Time.zone_offset(timezone)
        raise "Unable to parse timezone '#{timezone}'" unless !offset.nil?
        adjusted = time - offset
      end

      return Fluent::EventTime.from_time(adjusted), record
    end
  end
end
