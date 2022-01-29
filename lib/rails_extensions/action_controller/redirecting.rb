module ActionController
  module Redirecting

    private

    def _url_host_allowed?(url)
      Domain.matches_second_level? url, request.original_url
    rescue ArgumentError, URI::Error
      false
    end
  end
end