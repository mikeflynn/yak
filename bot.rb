#!/usr/bin/env ruby

require 'rubygems'
require 'xmpp4r/client'
require 'xmpp4r/roster'
require 'xmpp4r/vcard'
require 'pp'
require 'yaml'

class Yak
	include Jabber

	attr_accessor :jid, :password, :fullname, :nickname, :photo, :status, :admins, :priority, :api
	attr_reader :client, :roster	

	def initialize(config, debug = false)
		self.jid = config["username"]
		self.password = config["password"]
		self.fullname = config["fullname"]
		self.nickname = config["nickname"]
		self.status = config["status"]

		if(config["priority"].empty? == false)
			self.priority = config["priority"]
		else
			self.priority = 1;
		end

		if(config["photo"].empty? == false)
			self.photo = config["photo"]
		else
			self.photo = '';
		end

		if(config["log_file"].empty? == false)
			self.log_file = config["log_file"]
		else
			self.log_file = 'screen';
		end

		log("Connecting as "+@fullname+"...");

		@client = Client.new(JID::new(self.jid + '/yak'))
		Jabber::debug = debug

		connect
		set_metadata(@fullname, @nickname, @photo)
		add_callbacks
	end

	def connect
		@client.connect
		@client.auth(@password)

		change_status(@status, :chat, @priority)

		@roster = Roster::Helper.new(@client)

		log("Client connected!")
	end

	def add_callbacks
		
	end

	def send

	end

	def receive

	end

	def status

	end

	def signoff

	end

	def log

	end
end

if(ARGV[0] != '') 
	config = YAML.load_file(ARGV[0])
	bot = Yak.new(config, ARGV[1])
	Thread.stop
end

bot.signoff