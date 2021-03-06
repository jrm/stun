require 'stun/binary'
require 'stun/message/classes'
require 'stun/message/methods'

module Stun
  class Message
    class Header
      LENGTH = 160
      MAGIC_COOKIE = 0x2112A442
      TRANSACTION_ID_LENGTH = 96

      attr_accessor :message_class, :transaction_id

      def initialize(options = {})
        options = default_options.merge(options)
        self.message_class = options.fetch(:message_class)
        self.transaction_id = options.fetch(:transaction_id)
      end

      def payload
        [
          type,
          length,
          MAGIC_COOKIE,
          chunked_transaction_id
        ].flatten
      end

      def to_bytes
        # n  => type
        # n  => length
        # N  => MAGIC_COOKIE
        # N3 => chunked_transaction_id
        payload.pack('nnNN3')
      end

      def type
        message_class & message_method
      end

      def message_method
        Stun::Message::Methods::BINDING
      end

      def length
        LENGTH
      end

      def chunked_transaction_id
        Binary.chunked(transaction_id)
      end

      private

      def generate_transaction_id
        rand(2 ** TRANSACTION_ID_LENGTH)
      end

      def default_options
        {
          :message_class => Stun::Message::Classes::REQUEST,
          :transaction_id => generate_transaction_id
        }
      end
    end
  end
end
