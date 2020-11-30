require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  test "requires a valid url" do
    assert_raise ActiveRecord::RecordInvalid do
      Organization.new(name: "Org #1", description: "yep", organization_categories: [organization_categories(:health)]).save!
    end

    assert_raise ActiveRecord::RecordInvalid do
      Organization.new(name: "Org #1", description: "yep", url: "not a url", organization_categories: [organization_categories(:health)]).save!
    end

    assert_raise ActiveRecord::RecordInvalid do
      Organization.new(name: "Org #1", description: "yep", url: "http://example.com", organization_categories: [organization_categories(:health)]).save!
    end

    assert Organization.new(name: "Org #1", description: "yep", url: "https://example.com", organization_categories: [organization_categories(:health)]).save!
  end

  test "requires a name" do
    assert_raise ActiveRecord::RecordInvalid do
      Organization.new(description: "yep", url: "https://example.com").save!
    end
    assert Organization.new(name: "Org #1", description: "yep", url: "https://example.com", organization_categories: [organization_categories(:health)]).save!
  end

  test "requires a description" do
    assert_raise ActiveRecord::RecordInvalid do
      Organization.new(name: "Org #1", url: "https://example.com").save!
    end
    assert Organization.new(name: "Org #1", description: "yep", url: "https://example.com", organization_categories: [organization_categories(:health)]).save!
  end

  test "requires at least one category" do
    assert_raise ActiveRecord::RecordInvalid do
      Organization.new(name: "Org #1", description: "yep", url: "https://example.com").save!
    end
    assert Organization.new(name: "Org #1", description: "yep", url: "https://example.com", organization_categories: [organization_categories(:health)]).save!
  end
end
