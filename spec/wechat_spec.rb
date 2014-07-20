require File.expand_path '../spec_helper.rb', __FILE__

describe Sinatra::Wechat do
  include Rack::Test::Methods

  it "GET should have message verification" do
    def app
      instance = Sinatra.new do
        register Sinatra::Wechat
      end
      instance.wechat(:wechat_token => 'test-token') { }
    end

    get '/'
    expect(last_response.status).to eq(403)

    get '/', {:timestamp => '201407191804', 
              :nonce => 'nonce', 
              :signature => '9a91a1cea1cb60b87a9abb29dae06dce14721258',
              :echostr => 'echo string'}
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('echo string')
  end

  it "Can disable message validation" do
    def app
      instance = Sinatra.new do
        register Sinatra::Wechat
      end
      instance.wechat(:message_validation => false) { }
    end

    get '/'
    expect(last_response.status).to eq(200)
  end

  it "POST should have message verification" do
    def app
      instance = Sinatra.new do
        register Sinatra::Wechat
      end
      instance.wechat(:wechat_token => 'test-token') {
        text { 'text response' }
      }
    end
    post '/'
    expect(last_response.status).to eq(403)

    body = <<-EOF
      <xml>
      <ToUserName>tousername</ToUserName>
      <FromUserName>fromusername</FromUserName> 
      <CreateTime>1348831860</CreateTime>
      <MsgType>text</MsgType>
      <Content>This is the message content</Content>
      <MsgId>1234567890123456</MsgId>
      </xml>
    EOF

    post '/?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', body
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('text response')
  end

  it "can switch wechat endpoint" do
    def app
      instance = Sinatra.new do
        register Sinatra::Wechat
      end
      instance.wechat('/wechat', :wechat_token => 'test-token') {
        image { 'relocated response' }
      }
    end
    body = <<-EOF
      <xml>
      <ToUserName><![CDATA[toUser]]></ToUserName>
      <FromUserName><![CDATA[fromUser]]></FromUserName>
      <CreateTime>1348831860</CreateTime>
      <MsgType><![CDATA[image]]></MsgType>
      <PicUrl><![CDATA[this is a url]]></PicUrl>
      <MediaId><![CDATA[media_id]]></MediaId>
      <MsgId>1234567890123456</MsgId>
      </xml>
    EOF

    post '/?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', body
    expect(last_response.status).to eq(404)

    post '/wechat?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', body
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('relocated response')
    
  end

  it "should accept wechat message push" do
    def app
      instance = Sinatra.new do
        register Sinatra::Wechat
      end
      instance.wechat(:wechat_token => 'test-token') {
        text(:content => %r{regex match}) { 'regex match' }
        text(lambda {|values| values[:content] == 'function match'}) { 'function match' }
        text { 'default match' }
        voice {
          values = request[:wechat_values]
          values[:msg_id]
        }
        location {
          values = request[:wechat_values]
          values[:label]
        }
      }
    end

    post '/?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', <<-EOF
      <xml>
      <ToUserName>tousername</ToUserName>
      <FromUserName>fromusername</FromUserName> 
      <CreateTime>1348831860</CreateTime>
      <MsgType>text</MsgType>
      <Content>test regex match ...</Content>
      <MsgId>1234567890123456</MsgId>
      </xml>
    EOF
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('regex match')


    post '/?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', <<-EOF
      <xml>
      <ToUserName>tousername</ToUserName>
      <FromUserName>fromusername</FromUserName> 
      <CreateTime>1348831860</CreateTime>
      <MsgType>text</MsgType>
      <Content>function match</Content>
      <MsgId>1234567890123456</MsgId>
      </xml>
    EOF
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('function match')


    post '/?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', <<-EOF
      <xml>
      <ToUserName>tousername</ToUserName>
      <FromUserName>fromusername</FromUserName> 
      <CreateTime>1348831860</CreateTime>
      <MsgType>text</MsgType>
      <Content>default match</Content>
      <MsgId>1234567890123456</MsgId>
      </xml>
    EOF
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('default match')


    post '/?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', <<-EOF
      <xml>
      <ToUserName><![CDATA[toUser]]></ToUserName>
      <FromUserName><![CDATA[fromUser]]></FromUserName>
      <CreateTime>1357290913</CreateTime>
      <MsgType><![CDATA[voice]]></MsgType>
      <MediaId><![CDATA[media_id]]></MediaId>
      <Format><![CDATA[Format]]></Format>
      <MsgId>1234567890123456</MsgId>
      </xml>
    EOF
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('1234567890123456')

    post '/?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', <<-EOF
      <xml>
      <ToUserName><![CDATA[toUser]]></ToUserName>
      <FromUserName><![CDATA[fromUser]]></FromUserName>
      <CreateTime>1351776360</CreateTime>
      <MsgType><![CDATA[location]]></MsgType>
      <Location_X>23.134521</Location_X>
      <Location_Y>113.358803</Location_Y>
      <Scale>20</Scale>
      <Label><![CDATA[位置信息]]></Label>
      <MsgId>1234567890123456</MsgId>
      </xml>
    EOF
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('位置信息')

    post '/?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', <<-EOF
      <xml>
      <MsgType>unknown</MsgType>
      </xml>
    EOF
    expect(last_response.status).to eq(501)
  end

  it "should accept complex match" do
    def app
      instance = Sinatra.new do
        register Sinatra::Wechat
      end
      instance.wechat(:wechat_token => 'test-token') {
        future(lambda {|vs| vs[:to_user_name] == 'test' }, :content => %r{future}, :create_time => '1348831860') {
          'complex match'
        }
        range(:to_user_name => 'tesa'..'testz') { 'range match' }
      }
    end

    post '/?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', <<-EOF
      <xml>
      <ToUserName>test</ToUserName>
      <FromUserName>fromusername</FromUserName> 
      <CreateTime>1348831860</CreateTime>
      <MsgType>future</MsgType>
      <Content>Test future message type</Content>
      <MsgId>1234567890123456</MsgId>
      </xml>
    EOF
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('complex match')



    post '/?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', <<-EOF
      <xml>
      <ToUserName>test</ToUserName>
      <MsgType>range</MsgType>
      </xml>
    EOF
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('range match')
  end

  it "should raise error when invalid condition set" do
    instance = Sinatra.new do
      register Sinatra::Wechat
    end
    expect {
      instance.wechat(:wechat_token => 'test-token') {
        future('invalid condition') { 'complex match' }
      }
    }.to raise_exception
  end

  it "can have multiple endpoint" do
    def app
      instance = Sinatra.new do
        register Sinatra::Wechat
      end
      instance.wechat('/wechat1', :wechat_token => 'test-token') {
        selector = lambda do |values|
          x = values[:location_x].to_f
          20 < x && x < 30
        end
        location(selector) { 'matched location range' }
      }
      instance.wechat('/wechat2', :wechat_token => 'test') {
        text { 'this is another wechat endpoint' }
      }
      instance.wechat('/wechat3', :wechat_token => 'unknown', :message_validation => false) {
        text { 'disable message validation' }
      }
    end

    post '/wechat1?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', <<-EOF
      <xml>
      <MsgType><![CDATA[location]]></MsgType>
      <Location_X>23.134521</Location_X>
      <Location_Y>113.358803</Location_Y>
      <Scale>20</Scale>
      </xml>
    EOF
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('matched location range')


    post '/wechat2?timestamp=201407191804&nonce=nonce&signature=9a91a1cea1cb60b87a9abb29dae06dce14721258', '<xml><MsgType>text</MsgType></xml>'
    expect(last_response.status).to eq(403)


    post '/wechat2?timestamp=201407191804&nonce=nonce&signature=8149d14c72f418819b1eaab851aeab2c308f15cc', '<xml><MsgType>text</MsgType></xml>'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('this is another wechat endpoint')

    get '/wechat3?echostr=return'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('return')

    post '/wechat3', '<xml><MsgType>text</MsgType></xml>'
    expect(last_response.body).to eq('disable message validation')

  end
end