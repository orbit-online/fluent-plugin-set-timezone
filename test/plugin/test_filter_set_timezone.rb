# coding: utf-8
require 'helper'
require "fluent/test/helpers"
require "fluent/test/driver/filter"

class SetTimezoneFilterTest < Test::Unit::TestCase

  include Fluent::Test::Helpers

  def setup
    Fluent::Test.setup
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
  end

  CONFIG = %q!
    timezone_key tz
  !

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::SetTimezoneFilter).configure(conf)
  end

  def create_filter(conf)
    f = Fluent::Plugin::SetTimezoneFilter.new
    f.configure(Fluent::Config.parse(conf, "(test)", "(test_dir)", syntax: :v1))
    f
  end

  def filter(filter, time, source_zone, offset_diff, tz_overwrite)
    result = filter.filter_with_time('filter.test', event_time("#{time} #{source_zone}"), {'tz' => tz_overwrite})
    expect = event_time("#{time} #{offset_diff}")
    return expect, result[0]
  end

  sub_test_case 'configured with invalid configuration' do
    test 'empty configuration' do
      assert_raise(Fluent::ConfigError) do
         create_driver('')
      end
    end
  end

  test 'set to Europe/Copenhagen' do
    f = create_filter(CONFIG)
    assert_equal_event_time(*filter(f, '2016-11-03 15:58:09', 'UTC', '+01:00', 'Europe/Copenhagen'))
    assert_equal_event_time(*filter(f, '2020-10-03 09:45:19', 'UTC', '+02:00', 'Europe/Copenhagen'))
    assert_equal_event_time(*filter(f, '1985-01-15 10:05:01', 'EST', '-04:00', 'Europe/Copenhagen'))
    assert_equal_event_time(*filter(f, '1998-08-15 10:05:01', 'Z', '+02:00', 'CET'))
  end

  test 'match subsec' do
    f = create_filter(CONFIG)
    assert_equal_event_time(*filter(f, '2016-11-03 15:58:09.00013', 'UTC', '-04:00', 'America/New_York'))
    assert_equal_event_time(*filter(f, '2020-10-03 09:45:19.123', 'UTC', '+02:00', 'Europe/Copenhagen'))
    assert_equal_event_time(*filter(f, '1985-01-15 10:05:01.16548413', 'EST', '-04:00', 'Europe/Copenhagen'))
  end

  test 'set to offset' do
    f = create_filter(CONFIG)
    assert_equal_event_time(*filter(f, '2016-11-03 15:58:09.016824', 'UTC', '+02:00', '+0200'))
    assert_equal_event_time(*filter(f, '2020-10-03 09:45:19.4882', 'UTC', '-11:30', '-11:30'))
    assert_equal_event_time(*filter(f, '1985-01-15 10:05:01.1357444680', 'EST', '-05:00', 'Z'))
  end

  test 'return same on no tz' do
    f = create_filter(CONFIG)
    assert_equal_event_time(*filter(f, '2016-11-03 15:58:09.016824', 'UTC', '+00:00', ''))
    assert_equal_event_time(*filter(f, '2016-11-03 15:58:09.016824', 'UTC', '+00:00', nil))
  end

  test 'fail on invalid tz' do
    assert_raise(RuntimeError.new('Unable to parse timezone \'Sokovia/Novi_Grad\'')) do
      f = create_filter(CONFIG)
      filter(f, '2016-11-03 15:58:09.016824', 'UTC', '+00:00', 'Sokovia/Novi_Grad')
    end
  end

end
