require 'test_helper'

Validatable = Struct.new(:url) do
  include ActiveModel::Validations

  validates :url, presence: true, secure_url: true
end

class SecureUrlValidatorTest < ActiveSupport::TestCase
  test 'validates a url' do
    model = Validatable.new 'https://www.opensourcesociety.com'
    assert model.valid?
    assert_empty model.errors
  end

  test 'empty url is invalid' do
    model = Validatable.new ''
    assert_not model.valid?
    assert_not_empty model.errors
  end

  test 'nil url is invalid' do
    model = Validatable.new
    assert_not model.valid?
    assert_not_empty model.errors
  end

  test 'requires https url' do
    model = Validatable.new 'http://www.opensourcesociety.com'
    assert_not model.valid?
    assert_not_empty model.errors
  end

  test 'requires a host' do
    model = Validatable.new 'https://'
    assert_not model.valid?
    assert_not_empty model.errors
  end
end
