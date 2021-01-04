protocol = ENV.fetch('REDIS_PROTOCOL', 'redis:')
host = ENV.fetch('REDIS_HOST', 'localhost')
port = ENV.fetch('REDIS_PORT', '6379')
database = ENV.fetch('REDIS_DATABASE', '0')
ENV['REDIS_URL'] ||= "#{protocol}//#{host}:#{port}/#{database}"

puts "REDIS URL: #{ENV['REDIS_URL']}"
