# Used by Heroku (Procfile) and Docker. `rackup` alone also works for development.
threads_count = Integer(ENV.fetch('PUMA_MAX_THREADS', 5))
threads threads_count, threads_count

workers Integer(ENV.fetch('WEB_CONCURRENCY', 0))
preload_app!

port ENV.fetch('PORT', 9292)
environment ENV.fetch('RACK_ENV', 'development')
