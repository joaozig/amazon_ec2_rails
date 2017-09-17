redis = YAML.load(ERB.new(File.read(Rails.root.join('config', 'redis.yml'))).result)[Rails.env]

unless redis['redis_url'].present?
  puts 'Sidekiq is not configured, redis_url is blank.'
else
  Sidekiq.configure_server do |config|
    config.redis = { url: redis['redis_url'] }
    schedule_file = Rails.root.join('config', 'schedule.yml')

    if File.exists?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis['redis_url'] }
  end
end
