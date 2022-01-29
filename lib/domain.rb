class Domain
  def self.matches_second_level?(url, current)
    redirect_url = URI.parse url
    redirect_url.host.ends_with? second_level(current)
  rescue StandardError => e
    byebug
    Rails.logger.error e
  end

  def self.second_level(url)
    URI.parse(url).host
                  .split('.')
                  .last(2)
                  .join('.')
  end
end