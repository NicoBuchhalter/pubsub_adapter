class ExampleJob < ApplicationJob

	def perform(name)
		Example.create!(name: name)
	end
end