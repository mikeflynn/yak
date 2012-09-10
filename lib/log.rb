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

		if(!@output.nil? && @output != 'stdout')
			File.open(@output, 'w'){ |f| f.write(msg) }
		else
			puts msg
		end
	end
end