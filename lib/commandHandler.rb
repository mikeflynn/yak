class CommandHandler
	attr_accessor :type, :from, :body
	attr_reader :yak

	@@plugins = Array.new

	def initialize(yak, type, from, body)
		@yak = yak

		self.type = type
		self.from = from
		self.body = body
	end

	def run()
		parts = parse_body()

		if(parts["class"] == false)
			@yak.send(self.from, "I'm sorry, but I don't know that command.")
		else
			parts["class"].run(parts["message"]);
		end

	end

	def parse_body()
		obj = false
		body = self.body

		# Grab the first word and see if it's a command
		words = self.body.split(' ');
		cmd = words[0]

		@yak.get_logger().write("Command: "+cmd)

		@@plugins.each do |plugin|
			if(plugin.class.name == cmd)
				obj = plugin

				words.delete_at(0)
				body = words.join(' ')
				break
			end
		end

		return {
			"class" => obj,
			"message" => body
		}
	end

	def self.register(plugin)
		if(plugin.kind_of? CommandBase)
			@@plugins.push(plugin)
		end
	end

	def self.hasCommand(plugin)

	end

	def self.removeCommand(plugin)

	end

	def self.listCommands()

	end
end