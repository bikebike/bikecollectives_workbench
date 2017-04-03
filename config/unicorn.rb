rails_env = ENV['RAILS_ENV'] || 'production'

dir = 'rails'

# The rule of thumb is to use 1 worker per processor core available,
# however since we'll be hosting many apps on this server,
# we need to take a less aggressive approach
worker_processes 2

# We deploy with capistrano, so "current" links to root dir of current release
directory = '/home/workbench'
port = 8080

working_directory directory

# Listen on unix socket
listen "127.0.0.1:#{port}", :backlog => 64

pid "/home/workbench/#{ENV['RAILS_ENV']}.pid"

stderr_path "#{directory}/log/workbench.log"
stdout_path "#{directory}/log/workbench.log"
