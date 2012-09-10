class Log
	attr_reader :output

	def initialize(output = 'stdout')
		if(output != 'stdout' && File.writable?(output) == false)
			raise 'Log file not writable!'
		end

		@output = output
	end

	def write(msg)
		if(msg.class != String)
			msg = msg.to_s
		end

		msg = "#{Time.now}: "+msg

		if(@output == 'stdout')
			puts msg
		else
			File.open(@output, 'w'){ |f| f.write(msg) }
		end
	end
end