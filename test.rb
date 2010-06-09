#!/usr/local/bin/ruby

require 'my_yammer'
require 'yaml'

config = YAML.load(IO.read('config.yml'))
yammer = MyYammer.new(config)

if yammer.login
    puts "OK"
else
    puts "Fail"
    puts yammer.page.content
    exit 0
end

if yammer.private_message(:user => 'oki', :msg => 'message')
    puts "Ok. Posted."
else
    puts "Message not posted."
end
