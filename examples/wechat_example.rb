require 'sinatra'
require 'sinatra/wechat'
require 'nokogiri'

disable :message_validation
set :wechat_token, 'test-token'

location_event_reply = proc {
  content_type 'application/xml'
  values = request[:wechat_values]
  builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
    xml.xml {
      xml.ToUserName values[:from_user_name]
      xml.FromUserName values[:to_user_name]
      xml.CreateTime Time.now.to_i
      xml.MsgType "text"
      xml.Content 'This is a location response'
    }
  end
  builder.to_xml
}

wechat('/wechat') {
  location {
    instance_eval &location_event_reply
  }
  text(:content => %r/\d+/) {
    content_type 'application/xml'
    erb :text_response, :locals => request[:wechat_values]
  }
  image(lambda { |values| values[:from_user_name] == 'test' }) {
    content_type 'application/xml'
    values = request[:wechat_values]
    replies = [{
      :title => 'artitle 1 title',
      :description => 'article 1 description',
      :pic_url => 'http://www.xxxx.com/yyy.jpg',
      :url => 'http://www.xxxx.com/yyy.html'
    }, {
      :title => 'artitle 2 title',
      :description => 'article 2 description',
      :pic_url => 'http://zzz.com/foo.png',
      :url => 'http://zzz.com/bar.html'
    }]
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.xml {
        xml.ToUserName values[:from_user_name]
        xml.FromUserName values[:to_user_name]
        xml.CreateTime Time.now.to_i
        xml.MsgType "news"
        xml.ArticleCount replies.length
        xml.Articles {
          replies.each do |reply|
            xml.item {
              xml.Title reply.title
              xml.Description reply.description
              xml.PicUrl reply.pic_url
              xml.Url reply.url
            }
          end
        }
      }
    end
    builder.to_xml
  }
}


__END__
@@ text_response

<xml>
<ToUserName><%= from_user_name %></ToUserName>
<FromUserName><%= to_user_name %></FromUserName>
<CreateTime><%= Time.now.to_i %></CreateTime>
<MsgType>text</MsgType>
<Content><![CDATA[你好]]></Content>
</xml>
