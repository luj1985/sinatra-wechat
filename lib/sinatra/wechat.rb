['sinatra/base', 'blankslate', 'nokogiri'].each { |m| require m }

module Sinatra
  module Wechat
    module Endpoint
      # Work as a Ruby Builder, treat every Wechat 'MsgType' as method name
      # the method arguments are the Wechat message it self
      class DispatcherBuilder < ::BlankSlate
        def initialize(&block)
          @message_handlers = {}
          instance_eval(&block) if block_given?
        end

        # resp_blk is used to generate HTTP response, need to eval in Sinatra context
        def method_missing(sym, *args, &resp_blk)
          @message_handlers[sym] ||= []
          matchers = args.collect do |arg|
            if arg.respond_to?(:call) then lambda &arg
            # for named parameters
            elsif arg.respond_to?(:all?) then lambda { |values| arg.all? { |k,v| v === values[k]} }
            else raise TypeError, "\"#{v} (#{v.class})\" is not an acceptable condition"
            end
          end
          matcher = lambda { |values| matchers.all? { |m| m.call(values) } }
          @message_handlers[sym] << [ matcher, resp_blk ]
        end

        def dispatch!(values)
          return nil unless msg_type = values[:msg_type]
          handlers = @message_handlers[msg_type.to_sym] || []
          handlers.find { |m, _| m.call(values) }
        end
      end

      def wechat(endpoint = '/', wechat_token: '', validate_msg: true, &block)
        before endpoint do
          if validate_msg then
            raw = [wechat_token, params[:timestamp], params[:nonce]].compact.sort.join
            halt 403 unless Digest::SHA1.hexdigest(raw) == params[:signature]
          end
        end

        get endpoint do
          content_type 'text/plain'
          params[:echostr]
        end

        dispatcher = DispatcherBuilder.new(&block)

        post endpoint do
          body = request.body.read || ""
          halt 400 if body.empty?  # bad request, cannot handle this kind of message

          xmldoc = Nokogiri::XML(body).root
          values = xmldoc.element_children.each_with_object(Hash.new) do |e, v|
            name = e.name.gsub(/(.)([A-Z])/,'\1_\2').downcase
            # rename 'Location_X' to 'location__x' then to 'location_x'
            name = name.gsub(/(_{2,})/,'_')
            v[name.to_sym] = e.content
          end
          _, handler = dispatcher.dispatch!(values)
          halt 404 unless handler

          request[:wechat_values] = values
          instance_eval(&handler)
        end
        self
      end
    end

    def self.registered(application)
      application.extend(Wechat::Endpoint)
      Sinatra::Delegator.delegate(:wechat) # expose wechat method to classic style
    end
  end

  register Sinatra::Wechat
end