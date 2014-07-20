# Sinatra Wechat extension
[![Build Status](https://travis-ci.org/luj1985/sinatra-wechat.svg?branch=master)](https://travis-ci.org/luj1985/sinatra-wechat)

This extension is used to support [Tencent Wechat](https://mp.weixin.qq.com/) development mode.

## Installation

    $ gem install sinatra-wechat

# Usage

> use `disable :message_validation` to prevent message validation, otherwise need to add signature to the URL.

```ruby
# app.rb
require 'sinatra'
require 'sinatra/wechat'

disable :message_validation
set :wechat_token, 'test-token'

wechat('/') {
  text(:content => %r{\d+}) {
  	content_type 'application/xml'
  	erb :hello, :locals => request[:wechat_values]
  }
}

__END__
@@ hello
<xml>
  <ToUserName><%= from_user_name %></ToUserName>
  <FromUserName><%= to_user_name %></FromUserName>
  <CreateTime><%= Time.now.to_i %></CreateTime>
  <MsgType>text</MsgType>
  <Content><![CDATA[你好]]></Content>
</xml>
```

start server:
```sheel
$ ruby app.rb
```

Test via [cURL](http://curl.haxx.se):

```shell
$ curl -X POST --data '<xml>
<ToUserName>tousername</ToUserName>
<FromUserName>fromusername</FromUserName> 
<CreateTime>1348831860</CreateTime>
<MsgType>text</MsgType>
<Content>1345 match number</Content>
<MsgId>1234567890123456</MsgId>
</xml>' http://localhost:4567
```

The response is like:
``` xml
<xml>
<ToUserName>fromusername</ToUserName>
<FromUserName>tousername</FromUserName>
<CreateTime>1405790652</CreateTime>
<MsgType>text</MsgType>
<Content><![CDATA[你好]]></Content>
</xml>
```
