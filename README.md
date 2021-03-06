# Sinatra Wechat extension
[![Build Status](https://travis-ci.org/luj1985/sinatra-wechat.svg?branch=master)](https://travis-ci.org/luj1985/sinatra-wechat)
[![Gem Version](https://badge.fury.io/rb/sinatra-wechat.svg)](http://badge.fury.io/rb/sinatra-wechat)
[![Coverage Status](https://coveralls.io/repos/luj1985/sinatra-wechat/badge.png)](https://coveralls.io/r/luj1985/sinatra-wechat)

This extension is used to support [Tencent Wechat](https://mp.weixin.qq.com/) rapid development.

## Installation

    $ gem install sinatra-wechat

# Usage

Below code implement a simple wechat robot, reply text `你好` when message sent by end user contains number `%r{\d+}`.
> use `:validate_msg => false` to disable wechat message validation, otherwise need to append signature to the URL. The default value of `:validate_msg` is `true`

```ruby
# app.rb
require 'sinatra'
require 'sinatra/wechat'

wechat('/', :wechat_token => 'test-token', :validate_msg => false) {
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

start web server:
```shell
$ ruby app.rb
```

validate it via [cURL](http://curl.haxx.se):
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
