#!/usr/bin/env ruby

require 'rubygems'
require 'xmpp4r/client'
require 'xmpp4r/roster'
require 'xmpp4r/vcard'
require 'pp'
require 'yaml'
require 'lib/log'

class Yak
	include Jabber

	attr_accessor :jid, :password, :fullname, :nickname, :photo, :status, :admins, :priority, :api, :log_file
	attr_reader :client, :roster, :config, :log

	def initialize(config, debug = false)
		@log = Log.new(config["log_to"]);

		self.jid = config["username"]
		self.password = config["password"]
		self.fullname = config["fullname"]
		self.nickname = config["nickname"]
		self.status = config["status"]

		if(!config["priority"].nil?)
			self.priority = config["priority"]
		else
			self.priority = 1;
		end

		if(!config["photo"].nil?)
			self.photo = config["photo"]
		else
			self.photo = '';
		end

		@log.write("Connecting as '"+@fullname+"'...");

		@client = Client.new(JID::new(self.jid + '/yak'))
		Jabber::debug = debug

		connect
		set_metadata(@fullname, @nickname, @photo)
		callbacks
	end

	def connect
		@client.connect
		@client.auth(@password)

		change_status(@status, :chat, @priority)

		@roster = Roster::Helper.new(@client)

		@log.write("Client connected!")
	end

	def callbacks
		@log.write("Starting subscription callback...")

		# Auto-add new friend requests
		@roster.add_subscription_request_callback do |item,pres|
			@log.write("Incoming friend request from: "+pres.from.to_s)

			@roster.accept_subscription(pres.from)

			#x = Presence.new.set_type(:subscribe).set_to(pres.from)
			#@client.send(x)

			send(pres.from, "Hi new friend! Feel free to ask me some questions.")
		end

		@log.write("Starting message callback...")

		# Message responding...
		@client.add_message_callback do |t|
			if(t.body.to_s != '')
				@log.write("Incoming " + t.type.to_s + " message from " + t.from.to_s + ": " + t.body.to_s)
			end
		end
	end

	def set_metadata(full_name, nickname, image_file = '')
		avatar_sha1 = nil
		Thread.new do
			vcard_helper = Jabber::Vcard::Helper.new(@client)
			vcard = vcard_helper.get

			vcard["FN"] = full_name
			vcard["NICKNAME"] = nickname

			if (image_file != '')
				type = get_filetype(image_file)
				if(type)
					image_file = File.new(image_file, "r")
					vcard["PHOTO/TYPE"] = type
					image_b64 = Base64.encode64(image_file.read())
					#image_file.rewind
					avatar_sha1 = Digest::SHA1.hexdigest(image_file.read())
					vcard["PHOTO/BINVAL"] = image_b64
				end
			end
			begin
				vcard_helper.set(vcard)
			rescue Exception => e
				output "Vcard update failed: '#{e.to_s.inspect}'"
			end
		end
	end

	def change_status(message = '', type=:chat, priority = 1)
		@client.send(Jabber::Presence.new.set_show(type).set_status(message).set_priority(priority))
	end

	def add_callbacks
		
	end

	def send(to, body, subject = '')
		msg = Message::new
		msg.to = to

		msg.subject = subject
		msg.set_type(:normal)
		msg.set_id('1')

		if(body.class != String)
			body = body.to_s
		end

		msg.body = body

		@client.send(msg)
	end

	def receive

	end

	def status

	end

	def signoff
		@client.close

		@log.write("Client disconnected.")
	end
end

if(!ARGV[0].nil?)
	config = YAML.load_file(ARGV[0])
	bot = Yak.new(config, ARGV[1])
	Thread.stop
end

bot.signoff