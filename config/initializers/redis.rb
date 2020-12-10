ENV['REDIS_HOST'] ||= 'localhost'
ENV['REDIS_PORT'] ||= '6379'
ENV['REDIS_URL'] ||= "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}"
