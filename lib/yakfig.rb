class Yakfig
	@@config = nil

	def self.parse(path)
		@@config = YAML.load_file(ARGV[0])
	end

	def self.get(key, default = false)
		if(@@config.nil?)
			raise 'No config loaded!'
		end

		if(!@@config[key].nil?)
			return @@config[key]
		end

		return default
	end
end