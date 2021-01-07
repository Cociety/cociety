class Domain
  def self.matches_second_level_of_current?(url)
    redirect_url = URI.parse url
    redirect_url.host.ends_with? current
  rescue StandardError => e
    Rails.logger.error e
  end

  def self.current
    Rails.application.config.host
         .split('.')
         .last(2)
         .join('.')
  end
end