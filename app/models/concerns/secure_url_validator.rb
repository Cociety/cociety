class SecureUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, 'is not a valid HTTPS URL') unless is_secure_url?(value)
  end

  private

  def is_secure_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTPS) && uri.host.present?
  rescue StandardError
    false
  end
end
