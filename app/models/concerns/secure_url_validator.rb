class SecureUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless is_secure_url?(value)
      record.errors.add(attribute, "is not a valid HTTPS URL")
    end
  end

  private

  def is_secure_url?(url)
    begin
      uri = URI.parse(url)
      uri.is_a?(URI::HTTPS) && uri.host.present?
    rescue
      false
    end
  end
end