require 'sinatra/base'
require 'blankslate'
require 'nokogiri'

module Sinatra
  module Wechat
    module EndpointActions
      class WechatDispatcher < ::BlankSlate
        def initialize
          super
          @message_handlers = {}
        end

        def method_missing(sym, *args, &block)
          @message_handlers[sym] ||= []
          matchers = args.collect do |v|
            if v.respond_to?(:call) then lambda { |values| v.call(values) }
            # for named parameters
            elsif v.respond_to?(:all?) then lambda { |values| v.all? { |k,v| v === values[k]} }
            else raise TypeError, "\"#{v} (#{v.class})\" is not an acceptable condition"
            end 
          end
          matcher = lambda do |values| 
            matchers.all? {|m| m.call(values)}
          end
          @message_handlers[sym] << [ matcher, block ]
        end

        def route!(values)
          type = values[:msg_type].to_sym
          handlers = @message_handlers[type] || []
          _, handler = handlers.find { |m, _| m.call(values) }
          handler
        end
      end

      def wechat(endpoint = '/', &block)
        dispatcher = WechatDispatcher.new
        dispatcher.instance_eval &block

        get endpoint do
          halt 403 unless validate_messages
          ''
        end

        post endpoint do
          halt 403 unless validate_messages

          body = request.body.read || ""
          halt 501 if body.empty?

          doc = Nokogiri::XML(body).root
          values = doc.element_children.each_with_object(Hash.new) do |e, v|
            name = e.name.gsub(/(.)([A-Z])/,'\1_\2').downcase
            # rename 'Location_X' to 'location__x' then to 'location_x'
            name = name.gsub(/(_{2,})/,'_')
            v[name.to_sym] = e.content
          end
          handler = dispatcher.route!(values)
          halt 501 unless handler

          request[:wechat_values] = values
          instance_eval(&handler)
        end
        self
      end
    end

    def self.registered(app)
      app.extend(Wechat::EndpointActions)

      app.helpers do
        enable :message_validation

        def validate_messages
          token = settings.wechat_token || ""
          raw = [token, params[:timestamp], params[:nonce]].compact.sort.join
          settings.message_validation ? Digest::SHA1.hexdigest(raw) == params[:signature] : true
        end
      end
      # expose to classic style
      Delegator.delegate(:wechat)
    end
  end

  register Wechat
end