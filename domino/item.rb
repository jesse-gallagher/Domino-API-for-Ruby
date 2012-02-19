module Domino
	class Item
		attr_reader :name, :type, :value
		
		def initialize(parent, name, type, value)
			@parent = parent
			@name = name
			@type = type
			@value = value
		end
		
		def to_s
			{
				:name => @name,
				:type => @type,
				:value => @value
			}.to_s
		end
	end
end