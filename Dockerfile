ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}
RUN mkdir /plugin
WORKDIR /plugin
RUN gem install bundler
COPY Gemfile Gemfile.lock fluent-plugin-set-timezone.gemspec VERSION .gitignore ./
RUN bundle install
COPY Rakefile ./
COPY lib lib
COPY test test
CMD bundle exec rake test && bundle exec rake build
