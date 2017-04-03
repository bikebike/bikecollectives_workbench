rails_env = ENV['RAILS_ENV'] || 'production'

dir = 'rails'

# The rule of thumb is to use 1 worker per processor core available,
# however since we'll be hosting many apps on this server,
# we need to take a less aggressive approach
worker_processes 1

# We deploy with capistrano, so "current" links to root dir of current release
directory = '/home/bikecollectives_workbench'
port = 8084

working_directory directory

# Listen on unix socket
listen "127.0.0.1:#{port}", backlog: 64

pid "#{directory}/workbench.pid"

stderr_path "#{directory}/log/workbench.log"
stdout_path "#{directory}/log/workbench.log"
