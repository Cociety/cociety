Dir[File.join(Rails.root, 'lib', 'rails_extensions', '**/*.rb')].each do |file|
  require file
end