FROM ruby:2.7.2

ADD Gemfile /app/
ADD Gemfile.lock /app/
WORKDIR /app
RUN bundle update --bundler
RUN bundle install
ADD . /app

EXPOSE 5000
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "5000"]
