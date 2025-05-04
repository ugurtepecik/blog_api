# typed: true

module Dry
  module Monads
    class Result
      def self.[](*_args)
        self
      end
    end
  end
end
