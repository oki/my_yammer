

# require "#{ENV['HOME']}/ruby/foxyfox"+"/foxyfox.rb"
require 'rubygems'
require 'Mechanize'
require 'pp'
# require 'active_support'
# require 'action_view'

class MyYammer
    attr_reader :login, :password
    attr_reader :agent, :root_url

    def initialize(args={})
        @login = args[:login] || args['login']
        @password = args[:password] || args['password']

        @agent = Mechanize.new { |a|
            a.user_agent_alias = 'Mac Safari'
            a.max_history = 1
        }
        @root_url = 'https://www.yammer.com/login'
    end

    def login
        page = @agent.get(@root_url)

        login_form = page.forms.find { |f| f.action.to_s =~ /session/ }
        login_form.login = @login
        login_form.password = @password
        page = @agent.submit(login_form)

        page.content !~ /Incorrect user name or password/
    end


    def private_message(args={})
        user = args[:user]
        msg = args[:msg]

        puts "To: #{user}"
        puts " > #{msg}"

        user_url = @agent.page.uri.to_s << "/users/#{user}"
        pp user_url

        page = @agent.get(user_url)


        # puts page.content

        # form_with(:action => '/account/login.php')
        msg_form = page.forms.select { |f| f.action.to_s =~ %r(/messages) }[1]

        unless msg_form
            puts "Unable to find msg_form"
            return false
        end

        # login_form.send("thingy[page_url]=", params["url"])

        if page.content =~ /"feed_key":"(.*?)"/
            feed_key = $1
        end
        unless feed_key
            puts "Unable to get feed_key"
            return false
        end
        
        # authenticity_token      Q8I5PUohBT4Y
        ## puts "authenticity_token: #{msg_form.authenticity_token}"

        # feed_key                feed_user_id_net
        msg_form.add_field!('feed_key', feed_key)
        ## puts "feed_key: #{msg_form.feed_key}"

        # form_id                 send_a_private_message_form
        ## puts "form_id: #{msg_form.form_id}"

        # limit                   20
        msg_form.add_field!('limit', 20)
        ## puts "limit: #{msg_form.limit}"

        # message[body]           tesadomosc
        msg_form.send("message[body]=",msg)
        ## puts "message[body]: #{msg_form.send('message[body]')}"

        # message[broadcast]  
        ## puts "message[broadcast]: #{msg_form.send('message[broadcast]')}"

        # message[direct_to_id]   923312312332143143242
        ## puts "message[direct_to_id]: #{msg_form.send('message[direct_to_id]')}"

        # message[group_id]   
        ## puts "message[group_id]: #{msg_form.send('message[group_id]')}"

        # message[replied_to_id]  
        ## puts "message[replied_to_id]: #{msg_form.send('message[replied_to_id]')}"

        # message_popup           false
        ## puts "message_popup: #{msg_form.message_popup}"

        # newer_than              487182433523
        #!!! puts "newer_than: #{msg_form.newer_than}"

        # polling                 true
        msg_form.add_field!('polling', 'true')
        ## puts "polling: #{msg_form.polling}"

        # threaded                extended
        msg_form.add_field!('threaded', 'extended')
        ## puts "threaded: #{msg_form.threaded}"

        # to-field    
        ## puts "to-field: #{msg_form.send('to-field')}"

        # update  
        msg_form.add_field!('update', '')
        ## puts "update: #{msg_form.update}"

        page = @agent.submit(msg_form)

        page.content =~ /Your reply was posted/
    end

end
