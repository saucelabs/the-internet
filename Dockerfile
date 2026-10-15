FROM ruby:4.0.7-slim AS build
RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle config set --local without 'test e2e' && bundle install --jobs 4

FROM ruby:4.0.7-slim
WORKDIR /app
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY . .
ENV RACK_ENV=production PORT=5000
EXPOSE 5000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
