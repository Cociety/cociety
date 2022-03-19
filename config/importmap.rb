# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@rails/activestorage", to: "@rails--activestorage.js" # @7.0.1
pin "alpinejs" # @2.7.3
