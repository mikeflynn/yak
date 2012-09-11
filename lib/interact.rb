class Interact
	def self.greeting(name = '')
		greetings = [
			'Hi!',
			'Hello!',
			'Sup.',
			'Yo.',
			'Hey ##NAME##'
		]

		return greetings.sample.to_s.sub("##NAME##", name)
	end
end