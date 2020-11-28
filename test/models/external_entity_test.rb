require 'test_helper'

class ExternalEntityTest < ActiveSupport::TestCase
  test "finds by name" do
    name = external_entity_sources(:Stripe).name
    ExternalEntity.by_name(name).each do |e|
      assert_equal name, e.source.name
    end

    name = external_entity_sources(:Apple).name
    ExternalEntity.by_name(name).each do |e|
      assert_equal name, e.source.name
    end
  end
end
