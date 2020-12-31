module ApplicationHelper
  def title
    "Cociety#{ENV['RAILS_ENV'] == 'production' ? '' : " [#{ENV['RAILS_ENV']}]"}"
  end
end
