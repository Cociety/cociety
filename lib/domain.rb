class Domain
  def self.matches_second_level_of_current?(url, current)
    redirect_url = URI.parse url
    redirect_url.host.ends_with? current_second_level(current)
  rescue StandardError => e
    Rails.logger.error e
  end

  def self.current_second_level(current_url)
    URI.parse(current_url).host
         .split('.')
         .last(2)
         .join('.')
  end
end