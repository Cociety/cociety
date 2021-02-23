module ActionView
  module Helpers
    module ActiveModelInstanceTag
      def full_error_messages
        object.errors.full_messages_for @method_name
      end
    end
  end
end
