module ActionController
  module RequestForgeryProtection
    private
    # Modified to validate subdomains as well as this apps domain
    def valid_request_origin? # :doc:
      if forgery_protection_origin_check
        # We accept blank origin headers because some user agents don't send it.
        raise InvalidAuthenticityToken, NULL_ORIGIN_MESSAGE if request.origin == "null"
        request.origin.nil? || request.origin == request.base_url || Domain.matches_second_level?(request.origin, request.original_url)
      else
        true
      end
    end
  end
end
