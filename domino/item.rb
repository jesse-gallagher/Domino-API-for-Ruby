module Domino
	class Item
		attr_reader :name, :type, :value
		
		def initialize(name, type, value)
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
	
	#class RichTextItem
		
	#end
end