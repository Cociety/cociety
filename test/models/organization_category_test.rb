require 'test_helper'

class OrganizationCategoryTest < ActiveSupport::TestCase
  test 'refuses to save a duplicate category' do
    assert OrganizationCategory.new(category: 'some_random_category').save!
    assert_raise ActiveRecord::RecordNotUnique do
      OrganizationCategory.new(category: 'some_random_category').save!
    end
  end

  test 'refuses to save without a valid category' do
    assert_raise ActiveRecord::RecordInvalid do
      OrganizationCategory.new.save!
    end
    assert_raise ActiveRecord::RecordInvalid do
      OrganizationCategory.new(category: '').save!
    end
    assert_raise ActiveRecord::RecordInvalid do
      OrganizationCategory.new(category: 'a').save!
    end
    assert OrganizationCategory.new(category: 'some_random_category').save!
  end
end
