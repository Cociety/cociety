# Rails Validator to test if a value is a secure url
# Example
# class HasSecureUrlProperty < ActiveRecord::Base
#   validates :url_property, presence: true, secure_url: true
# end
class SecureUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, 'is not a valid HTTPS URL') unless secure_url?(value)
  end

  private

  def secure_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTPS) && uri.host.present?
  rescue StandardError
    false
  end
end
