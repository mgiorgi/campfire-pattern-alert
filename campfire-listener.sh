#!/usr/bin/env ruby
require 'rubygems'
require 'tinder'
require 'xmpp4r-simple'
require 'campfire-configuration.rb'

# check parameters
if ARGV.length < 1
  puts "wrong number of arguments"
  puts "usage: campfire_client pattern [STDOUT|JABBER]"
  exit
end
# Constant values
DEFAULT_DELIVERY = 'STDOUT'
JABBER_DELIVERY = 'jabber'
MAX_FOLLOWING_MESSAGES_AFTER_USERNAME = 6

# Setting parameters from STDIN
pattern = ARGV[0]
delivery = ARGV[1] ? ARGV[1] : DEFAULT_DELIVERY

# Setting up Jabber connection if needed
if delivery.downcase == JABBER_DELIVERY
  puts "Loading Jabber configuration..."
  require 'jabber-configuration'
  puts "Jabber configuration loaded."
  puts "Setting up Jabber connection."
  jabber = Jabber::Simple.new(JABBER_LOGIN_USERNAME, JABBER_LOGIN_PASSWORD)
  puts "Jabber connection established."
end
# Setting up Campfire connection
puts "Campfire: Domain='#{CAMPFIRE_DOMAIN}' room='#{CAMPFIRE_ROOM}'"
campfire = Tinder::Campfire.new CAMPFIRE_DOMAIN
puts "Campfire: Login in..."
campfire.login CAMPFIRE_USERNAME, CAMPFIRE_PASSWORD
puts "Campfire: Login accomplished!"
puts "Campfire: Entering room #{CAMPFIRE_ROOM}"
room = campfire.find_room_by_name CAMPFIRE_ROOM
puts "Campfire: Entered in room #{CAMPFIRE_ROOM}"
read_following = 0
while true
  room.listen do |m|
    if m[:message].match(/^.*#{pattern}.*$/)
      read_following = MAX_FOLLOWING_MESSAGES_AFTER_USERNAME
    else
      read_following = read_following > 0 ? read_following - 1 : 0
    end
    if read_following > 0
      message = "#{m[:person]}: #{m[:message]}."
      if delivery == DEFAULT_DELIVERY
        puts message
      else
        jabber.deliver(JABBER_TARGET_USERNAME, message)
      end
    end
  end
end
